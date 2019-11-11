module CreateFactureAcompte
    ## FacturesController : Création de la Facture d'Acompte ------------------------------------
    def create_facture_acompte_trait
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
end