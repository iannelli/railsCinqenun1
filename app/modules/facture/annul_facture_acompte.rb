module AnnulFactureAcompte
    ##Création Facture d'Avoir de l'Acompte, Maj Facture Acompte Annulé et Maj Projet
    def annul_facture_acompte_trait
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
        @factureAvoir.facMontBrutHt = @factureAvoirArray[5].to_s
        @factureAvoir.facImputProjet = '000'
        @factureAvoir.facImputClient = '000'
        @factureAvoir.facMontNetHt = @factureAvoirArray[6].to_s
        @factureAvoir.facAcomTaux = @factureAvoirArray[7].to_s
        @factureAvoir.facAcomMont = '000'
        @factureAvoir.facMontTva = @factureAvoirArray[8].to_s
        @factureAvoir.facTypeTvaImpot = @factureAvoirArray[9].to_s        
        #@factureAvoir.facDeboursTtc = '000'
        #@factureAvoir.facDeboursTva = '000'
        #@factureAvoir.facDeboursImput = '000'
        @factureAvoir.facTotalDu = @factureAvoirArray[10].to_s
        @factureAvoir.facReglMont = @factureAvoirArray[11].to_s
        @factureAvoir.modePaieLib = @factureAvoirArray[12].to_s
        @factureAvoir.facDifference = '000'
        @factureAvoir.facLignes = ''
        @factureAvoir.facDepass = '0'
        @factureAvoir.facCourrier = ''
        @factureAvoir.facReA = ''
        @factureAvoir.projetId = @factureAvoirArray[14].to_s
        @factureAvoir.parametreId = params[:parametre][:id].to_s
        begin
            @factureAvoir.save
        rescue => e  # Incident Création Facture d'Avoir (Acompte)
            @erreur = Erreur.new
            @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
            @erreur.appli = "1"
            @erreur.origine = "Module[annulFactureAcompte]: erreur Création Facture d'Avoir de l'Acompte"
            @erreur.numLigne = '41'
            @erreur.message = e.message
            @erreur.parametreId = params[:parametre][:id].to_s
            @erreur.save
            @erreurUpdate = 3
        end
        if @erreurUpdate == 0 ## Maj Facture Annulée ----------------------
            begin
                @factureannul = Facture.find(@factureAvoirArray[13].to_i)
                @factureannul.facStatut = "3Annulé"
                @factureannul.facMention = "**** Facture Annulée ****"
                @factureannul.save
            rescue => e  # Incident Maj Facture Annulée
                @erreur = Erreur.new
                @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                @erreur.appli = "1"
                @erreur.origine = "Module[annulFactureAcompte]: erreur Find Facture Annulée - Facture.id=@factureAvoirArray[13].to_i " + @factureAvoirArray[13].to_s
                @erreur.numLigne = '55'
                @erreur.message = e.message
                @erreur.parametreId = params[:parametre][:id].to_s
                @erreur.save
                @erreurUpdate = 3
            end
         end
         if @erreurUpdate == 0 ## Maj Projet ----------------------
            begin
                @projet = Projet.find(@factureAvoirArray[14].to_i)
                @proNumRangArray = @projet.proNumRang.split("|")
                numRang = @proNumRangArray[1].to_i
                numRang -= 1
                @proNumRangArray[1] = numRang
                @projet.proNumRang = @proNumRangArray.join('|') 
                @projet.proFacHt = '000'
                @projet.proReglMont = '000'
                @projet.proReportFacture = '000'
                @projet.proReportDebours = '000'
                @projet.proSituation = '00'
                @projet.majDate = @current_time.strftime "%d/%m/%Y"
                @projet.save
            rescue => e  # Incident Maj Projet
                @erreur = Erreur.new
                @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                @erreur.appli = "1"
                @erreur.origine = "Module[annulFactureAcompte]: erreur Find Projet.id(@factureAvoirArray[14].to_i)= " + @factureAvoirArray[14].to_s
                @erreur.numLigne = '73'
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
                @erreur.appli = "1"
                @erreur.origine = "Module[annulFactureAcompte]: erreur Maj Parametre (parNumFact)"
                @erreur.numLigne = '101'
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