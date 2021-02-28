module ProjetArchivageFacture
    # Archivage des Factures en Facturesold
    def projet_archivage_facture_trait(projet)
        projet.factures.each do |facture|
            # Vérification présence de Factureold
            @factureold1 = Factureold.where("id = ?", facture.id).first
            unless @factureold1.nil? # Suppression de la Factureold
                @factureold1.destroy
            end
            @factureold = Factureold.new
            @factureold.id = facture.id
            @factureold.typeImpr = facture.typeImpr
            @factureold.facStatut = facture.facStatut
            @factureold.facDateEmis = facture.facDateEmis
            @factureold.facDelai = facture.facDelai
            @factureold.facDelaiMax = facture.facDelaiMax
            @factureold.facDateLimite = facture.facDateLimite
            @factureold.facDateReception = facture.facDateReception
            @factureold.facRef = facture.facRef
            @factureold.facBdC = facture.facBdC
            @factureold.facRefPre = facture.facRefPre
            @factureold.facProCom = facture.facProCom
            @factureold.facBdcSigne = facture.facBdcSigne
            @factureold.facMention = facture.facMention
            @factureold.facMontBrutHt = facture.facMontBrutHt
            @factureold.facImputProjet = facture.facImputProjet
            @factureold.facImputClient = facture.facImputClient
            @factureold.facMontNetHt = facture.facMontNetHt
            @factureold.facAcomTaux = facture.facAcomTaux
            @factureold.facAcomMont = facture.facAcomMont
            @factureold.facMontTva = facture.facMontTva
            @factureold.facTypeTvaImpot = facture.facTypeTvaImpot
            @factureold.facDeboursTtc = facture.facDeboursTtc
            @factureold.facDeboursTva = facture.facDeboursTva
            @factureold.facDeboursImput = facture.facDeboursImput
            @factureold.facTotalDu = facture.facTotalDu
            @factureold.facReglMont = facture.facReglMont
            @factureold.modePaieLib = facture.modePaieLib
            @factureold.facDifference = facture.facDifference
            @factureold.facLignes = facture.facLignes
            @factureold.facDepass = facture.facDepass
            @factureold.facCourrier = facture.facCourrier
            @factureold.facReA = facture.facReA
            @factureold.projetoldId = facture.projetId
            @factureold.parametreoldId = facture.parametreId
            begin
                @factureold.save
            rescue => e # erreur Factureold Create
                @erreur = Erreur.new
                @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                @erreur.appli = '1'
                @erreur.origine = 'Module[ProjetArchivageFacture]: Incident Save Factureold - facture.id=' + facture.id.to_s
                @erreur.numLigne = '42'
                @erreur.message = e.message
                @erreur.parametreId = params[:id].to_s
                @erreur.save
                @erreurArchivage = 1
                break
            end
        end
    end
end