module CreateFactureAcompte
    ## FacturesController : Création de la Facture d'Acompte ------------------------------------
    def create_facture_acompte_trait
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
        @factureAcompte.facMontBrutHt = @factureAcompteArray[5].to_s
        #@factureAcompte.facImputProjet = '000'
        #@factureAcompte.facImputClient = '000'
        @factureAcompte.facMontNetHt = @factureAcompteArray[5].to_s
        @factureAcompte.facAcomTaux = @factureAcompteArray[6].to_s
        @factureAcompte.facAcomMont = ''
        @factureAcompte.facMontTva = @factureAcompteArray[7].to_s
        @factureAcompte.facTypeTvaImpot = @factureAcompteArray[8].to_s
        #@factureAcompte.facDeboursTtc = '000'
        #@factureAcompte.facDeboursTva = '000'
        #@factureAcompte.facDeboursImput = '000'
        @factureAcompte.facTotalDu = '000'
        @factureAcompte.facReglMont = @factureAcompteArray[9].to_s
        @factureAcompte.modePaieLib = @factureAcompteArray[10].to_s
        #@factureAcompte.facDifference = '000'
        @factureAcompte.facLignes = ''
        @factureAcompte.facDepass = ''
        @factureAcompte.facCourrier = ''
        @factureAcompte.facReA = ''
        @factureAcompte.projetId = @factureAcompteArray[11].to_s
        @factureAcompte.parametreId = @factureAcompteArray[12].to_s
        begin
            @factureAcompte.save
        rescue => e  # Incident Création Facture Acompte
            @erreur = Erreur.new
            @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
            @erreur.appli = "1"
            @erreur.origine = "Module[createFactureAcompte]: erreur Création Facture Acompte"
            @erreur.numLigne = '40'
            @erreur.message = e.message
            @erreur.parametreId = params[:parametre][:id].to_s
            @erreur.save
            @erreurUpdate = 2
        end
        if @erreurUpdate == 0 ## Maj Projet.proNumRang et Projet.proFacHt ----------------------
            begin
                @projet = Projet.find(params[:projet][:id])
                @proNumRangArray = @projet.proNumRang.split("|")
                numRang = @proNumRangArray[1].to_i
                numRang += 1
                @proNumRangArray[1] = numRang
                @projet.proNumRang = @proNumRangArray.join('|')
                @projet.proFacHt = params[:projet][:proFacHt]
                @projet.save
            rescue => e  # Incident Maj Projet
                @erreur = Erreur.new
                @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                @erreur.appli = "1"
                @erreur.origine = "Module[createFactureAcompte]: erreur Find Projet.id=params[:projet][:id] " + params[:projet][:id].to_s
                @erreur.numLigne = '54'
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
                @erreur.appli = "1"
                @erreur.origine = "Module[createFactureAcompte]: erreur Maj Parametre.parNumFact"
                @erreur.numLigne = '77'
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