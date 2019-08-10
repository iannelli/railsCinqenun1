class ApplicationController < ActionController::Base

    protect_from_forgery

    #  FacturesController : MISE A JOUR du dernier Numéro de facture ------------------------------------
    def updateParametreNumFact
        @current_time = DateTime.now
        begin
            @paramun.parNumFact = params[:parametre][:parNumFact].to_s
            @paramun.save
        rescue => e  # Incident Maj Parametre
            @erreur = Erreur.new
            @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
            @erreur.appli = "rails - FacturesController[Create] - ApplicationController[updateParametreNumFact]"
            @erreurCreate = 1         
            @erreur.origine = "erreur Maj Parametre - ApplicationController[updateParametreNumFact]"
            @erreur.numLigne = '10'
            @erreur.message = e.message
            @erreur.parametreId = params[:parametre][:id].to_s
            @erreur.save
        end
    end


    ## FacturesController : MISE A JOUR des Tache.tacFacString et Tache.statut ------------------------------------
    def updateTacFacString
        t = 0
        ## A partir de @tacFacArray (Facture0.paramTacheTacFacString0) MAJ de Tache.tacFacString et de Facture.majTache
        while (t < @tacFacArray.length)
            tacFacElementArray = @tacFacArray[t].split('|')
            e = 0
            while (e < tacFacElementArray.length)
                if params[:operation][:maj] == 'C'
                    if (tacFacElementArray[e+2].to_s == 'F' && tacFacElementArray[e+4].to_s == '.')
                       tacFacElementArray[e+4] = @facture.id
                    end
                    if (tacFacElementArray[e+2].to_s == 'L')
                       tacFacElementArray[e+2] = '.'
                       tacFacElementArray[e+3] = '.'
                       tacFacElementArray[e+4] = '.'
                    end
                end
                if params[:operation][:maj] == 'R'
                    if (tacFacElementArray[e+2].to_s == 'F' && tacFacElementArray[e+4].to_i == @facture.id)
                       tacFacElementArray[e+2] = 'R'
                    end
                end
                if params[:operation][:maj] == 'RImp'
                    if (tacFacElementArray[e+2].to_s == 'F' && tacFacElementArray[e+4].to_i == @facture.id)
                       tacFacElementArray[e+2] = 'I'
                    end
                end
                e += 5
            end
            begin
                @tache = Tache.find(tacFacElementArray[0].to_i)
                totalTacheHt = 0
                nbrePeriodeFacturee = 0 # Nombre de période au Statut "Facturé"
                nbrePeriodeReglee = 0 # Nombre de période au Statut "Réglé" ou "Imputé"
                e = 0
                while (e < tacFacElementArray.length)
                    if tacFacElementArray[e+3] != "." ## montHt
                        totalTacheHt += tacFacElementArray[e+3].to_i
                    end
                    if tacFacElementArray[e+2] == "F"
                        nbrePeriodeFacturee += 1
                    end
                    if tacFacElementArray[e+2] == "R" || tacFacElementArray[e+2] == "I"
                        nbrePeriodeReglee += 1
                    end
                    e += 5
                end
                max = tacFacElementArray.length / 5
                if nbrePeriodeReglee == max
                    @tache.tacStatut = "3Réglé"
                end
                if nbrePeriodeFacturee == max
                    @tache.tacStatut = "3Facturé"
                end
                if nbrePeriodeFacturee > 0 && nbrePeriodeFacturee < max
                    @tache.tacStatut = "3miFacturé"
                end
                if nbrePeriodeFacturee == 0 && nbrePeriodeReglee == 0
                    @tache.tacStatut = "0enCours"
                end
                @tache.tacFacString = tacFacElementArray.join('|')
                @tache.tacFacHt = totalTacheHt
                @tache.tacMarge = totalTacheHt - @tache.tacCout.to_i
                begin
                    @tache.save
                    ## Création de Facture.majTache ------
                    @majTache[@indMajTache] = @tache.id
                    @indMajTache += 1
                    @majTache[@indMajTache] = @tache.tacFacString
                    @indMajTache += 1
                    @majTache[@indMajTache] = @tache.tacStatut
                    @indMajTache += 1
                    @majTache[@indMajTache] = totalTacheHt
                    @indMajTache += 1
                    t += 1
                rescue => e  # Incident Save Tache
                    @erreur = Erreur.new
                    current_time = DateTime.now
                    @erreur.dateHeure = current_time.strftime "%d/%m/%Y %H:%M:%S"
                    if @@origine == 'C'
                        @erreur.appli = "rails - FacturesController - create"
                        @erreurCreate = 1
                    else
                        @erreur.appli = "rails - FacturesController - update"
                        @erreurUpdate = 1
                    end
                    @erreur.origine = "erreur Save Tache - @tache.id=" + @tache.id.to_s
                    @erreur.numLigne = '368'
                    @erreur.message = e.message
                    @erreur.parametreId = params[:parametre][:id].to_s
                    @erreur.save
                    break
                end
            rescue => e  # Incident Find Tache
                @erreur = Erreur.new
                current_time = DateTime.now
                @erreur.dateHeure = current_time.strftime "%d/%m/%Y %H:%M:%S"
                if @@origine == 'C'
                    @erreur.appli = "rails - FacturesController - Create - updateTacFacString"
                    @erreurCreate = 1
                else
                    @erreur.appli = "rails - FacturesController - Update - updateTacFacString"
                    @erreurUpdate = 1
                end
                @erreur.origine = "erreur Find Tache - tacFacElementArray[0]=" + tacFacElementArray[0].to_s
                @erreur.numLigne = '334'
                @erreur.message = e.message
                @erreur.parametreId = params[:parametre][:id].to_s
                @erreur.save
                break
            end
        end ## end while ---
    end


    ## FacturesController : Création de la Facture d'Acompte ------------------------------------
    def createFactureAcompte
        @factureAcompteArray = params[:acompte][:createFacAcompteString].split('|')
        @factureAcompte = Facture.new()
        @factureAcompte.typeImpr = '20'
        @factureAcompte.facStatut = '3Validé'
        @factureAcompte.facDateEmis = @factureAcompteArray[0].to_s
        @factureAcompte.facDelai = ''
        @factureAcompte.facDelaiMax = '0'
        @factureAcompte.facDateLimite = ''
        @factureAcompte.facDateReception = @factureAcompteArray[1].to_s
        @factureAcompte.facRef = @factureAcompteArray[2].to_s
        @factureAcompte.facBdC = @factureAcompteArray[3].to_s
        @factureAcompte.facRefPre = @factureAcompteArray[4].to_s
        @factureAcompte.facProCom = ''
        @factureAcompte.facBdcSigne = ''
        @factureAcompte.facMention = ''
        @factureAcompte.facMontTtc = @factureAcompteArray[5].to_s
        @factureAcompte.facMontHt = @factureAcompteArray[6].to_s
        @factureAcompte.facMontTva = @factureAcompteArray[7].to_s
        @factureAcompte.facAcomTaux = @factureAcompteArray[8].to_s
        @factureAcompte.facAcomMont = ''
        #@factureAcompte.facImputProjet = '000'
        #@factureAcompte.facImputClient = '000'
        #@factureAcompte.facDifference = '000'
        @factureAcompte.facTotalDu = '000'
        @factureAcompte.modePaieLib = @factureAcompteArray[9].to_s
        @factureAcompte.facReglMont = @factureAcompteArray[10].to_s
        @factureAcompte.facStringLigne = ''
        @factureAcompte.majTache = ''
        @factureAcompte.facDepass = ''
        @factureAcompte.facTypeDecla = @factureAcompteArray[11].to_s
        @factureAcompte.facCourrier = ''
        @factureAcompte.facReA = ''
        @factureAcompte.projetId = @factureAcompteArray[12].to_s
        @factureAcompte.parametreId = @factureAcompteArray[13].to_s
        begin
            @factureAcompte.save
        rescue => e  # Incident Création Facture Acompte
            @erreur = Erreur.new
            @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
            @erreur.appli = "rails - FacturesController - ApplicationController[createFactureAcompte]"
            @erreur.origine = "erreur Création Facture Acompte"
            @erreur.numLigne = '178'
            @erreur.message = e.message
            @erreur.parametreId = params[:parametre][:id].to_s
            @erreur.save
            @erreurUpdate = 2
        end
        if @erreurUpdate == 0 ## Maj Projet.proNumRang ----------------------
            begin
                @projet = Projet.find(params[:projet][:id])
                @proNumRangArray = @projet.proNumRang.split("|")
                numRang = @proNumRangArray[1].to_i
                numRang += 1
                @proNumRangArray[1] = numRang
                @projet.proNumRang = @proNumRangArray.join('|')
                @projet.save
            rescue => e  # Incident Maj Projet
                @erreur = Erreur.new
                @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                @erreur.appli = "rails - FacturesController[Update] - ApplicationController[createFactureAcompte]"
                @erreur.origine = "erreur Maj Projet.proNumrang - ApplicationController[createFactureAcompte]"
                @erreur.numLigne = '198'
                @erreur.message = e.message
                @erreur.parametreId = params[:parametre][:id].to_s
                @erreur.save
                @erreurUpdate = 2
            end
         end
         if @erreurUpdate == 0 ## Maj Parametre.parNumFact ----------------------
            begin
                @paramun.parNumFact = @factureAcompte.facRef.slice(5,5)
                @paramun.save
            rescue => e  # Incident Maj Parametre
                @erreur = Erreur.new
                @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                @erreur.appli = "rails - FacturesController[Update] - ApplicationController[createFactureAcompte]"
                @erreur.origine = "erreur Maj Parametre - ApplicationController[createFactureAcompte]"
                @erreur.numLigne = '192'
                @erreur.message = e.message
                @erreur.parametreId = params[:parametre][:id].to_s
                @erreur.save
                @erreurUpdate = 2
            end
        end
        if @erreurUpdate == 0 ## Fin du Traitement --------------------
            @erreurUpdate = 4
        end
    end


    ##Création Facture d'Avoir de l'Acompte, Maj Facture Acompte Annulé et Maj Projet
    def annulFactureAcompte
        @factureAvoirArray = params[:acompte][:annulFacAcompteString].split('|')
        @factureAvoir = Facture.new()
        @factureAvoir.typeImpr = '60'
        @factureAvoir.facStatut = '3Validé'
        @factureAvoir.facDateEmis = @factureAvoirArray[0].to_s
        @factureAvoir.facDelai = ''
        @factureAvoir.facDelaiMax = '0'
        @factureAvoir.facDateLimite = ''
        @factureAvoir.facDateReception = @factureAvoirArray[1].to_s
        @factureAvoir.facRef = @factureAvoirArray[2].to_s
        @factureAvoir.facBdC = @factureAvoirArray[3].to_s
        @factureAvoir.facRefPre = @factureAvoirArray[4].to_s
        @factureAvoir.facProCom = 'false'
        @factureAvoir.facBdcSigne = 'false'
        @factureAvoir.facMention = ''
        @factureAvoir.facMontHt = @factureAvoirArray[5].to_s
        @factureAvoir.facMontTva = @factureAvoirArray[6].to_s
        @factureAvoir.facMontTtc = @factureAvoirArray[7].to_s
        @factureAvoir.facAcomTaux = @factureAvoirArray[8].to_s
        @factureAvoir.facAcomMont = '000'
        @factureAvoir.facImputProjet = '000'
        @factureAvoir.facImputClient = '000'
        @factureAvoir.facDifference = '000'
        @factureAvoir.facTotalDu = '000'
        @factureAvoir.modePaieLib = @factureAvoirArray[9].to_s
        @factureAvoir.facReglMont = @factureAvoirArray[10].to_s
        @factureAvoir.facStringLigne = ''
        @factureAvoir.majTache = ''
        @factureAvoir.facDepass = ''
        @factureAvoir.facTypeDecla = @factureAvoirArray[11].to_s
        @factureAvoir.facCourrier = ''
        @factureAvoir.facReA = ''
        @factureAvoir.projetId = @factureAvoirArray[13].to_s
        @factureAvoir.parametreId = params[:parametre][:id].to_s
        begin
            @factureAvoir.save
        rescue => e  # Incident Création Facture d'Avoir (Acompte)
            @erreur = Erreur.new
            @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
            @erreur.appli = "rails - FacturesController - ApplicationController[annulFactureAcompte]"
            @erreur.origine = "erreur Création Facture Acompte"
            @erreur.numLigne = '183'
            @erreur.message = e.message
            @erreur.parametreId = params[:parametre][:id].to_s
            @erreur.save
            @erreurUpdate = 3
        end
        if @erreurUpdate == 0 ## Maj Facture Annulée ----------------------
            begin
                @factureannul = Facture.find(@factureAvoirArray[12].to_i)
                @factureannul.facStatut = "3Annulé"
                @factureannul.facMention = "**** Facture Annulée ****"
                @factureannul.save
            rescue => e  # Incident Maj Facture Annulée
                @erreur = Erreur.new
                @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                @erreur.appli = "rails - FacturesController[Update] - ApplicationController[annulFactureAcompte]"
                @erreur.origine = "erreur Maj Facture Annulée - ApplicationController[annulFactureAcompte]"
                @erreur.numLigne = '287'
                @erreur.message = e.message
                @erreur.parametreId = params[:parametre][:id].to_s
                @erreur.save
                @erreurUpdate = 3
            end
         end
         if @erreurUpdate == 0 ## Maj Projet ----------------------
            begin
                @projet = Projet.find(@factureAvoirArray[13].to_i)
                @proNumRangArray = @projet.proNumRang.split("|")
                numRang = @proNumRangArray[1].to_i
                numRang -= 1
                @proNumRangArray[1] = numRang
                @projet.proNumRang = @proNumRangArray.join('|') 
                @projet.proFacHt = '000'
                @projet.proReglMont = '000'
                @projet.proReport = '000'
                @projet.proSituation = '00'
                @projet.majDate = @factureAvoirArray[14].to_s
                @projet.save
            rescue => e  # Incident Maj Projet
                @erreur = Erreur.new
                @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                @erreur.appli = "rails - FacturesController[Update] - ApplicationController[annulFactureAcompte]"
                @erreur.origine = "erreur Maj Projet.proNumrang - ApplicationController[annulFactureAcompte]"
                @erreur.numLigne = '312'
                @erreur.message = e.message
                @erreur.parametreId = params[:parametre][:id].to_s
                @erreur.save
                @erreurUpdate = 3
            end
         end
         if @erreurUpdate == 0 ## Maj Parametre.parNumFact ----------------------
            begin
                @paramun.parNumFact = @factureAvoir.facRef.slice(5,5)
                @paramun.save
            rescue => e  # Incident Maj Parametre
                @erreur = Erreur.new
                @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                @erreur.appli = "rails - FacturesController[Update] - ApplicationController[annulFactureAcompte]"
                @erreur.origine = "erreur Maj Parametre - ApplicationController[annulFactureAcompte]"
                @erreur.numLigne = '328'
                @erreur.message = e.message
                @erreur.parametreId = params[:parametre][:id].to_s
                @erreur.save
                @erreurUpdate = 3
            end
        end
        if @erreurUpdate == 0 ## Fin du Traitement --------------------
            @erreurUpdate = 5
        end  

    end

end
