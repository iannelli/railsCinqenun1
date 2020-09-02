module ArchivageFactureCreate
    # Création des Factureold du Projetold ---
    def archivage_facture_create_trait
        @projet.factures.each do |facture|
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
                @erreurold = Erreurold.new
                @erreurold.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                @erreurold.appli = '1'
                @erreurold.origine = 'Module[ArchivageFactureCreate]: Incident Create Factureold - facture.id=' + facture.id.to_s
                @erreurold.numLigne = '42'
                @erreurold.message = e.message
                @erreurold.parametreoldId = params[:parametre][:parametreId].to_s
                @erreurold.save
                @erreurArchivage = 1
                break
            end
        end
    end
end