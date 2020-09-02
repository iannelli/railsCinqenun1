module ReactivationFactureCreate
    # Création des Factures du Projet Réactivé ---
    def reactivation_facture_create_trait
        @projetold.factureolds.each do |factureold|
            @facture = Facture.new
            @facture.id = factureold.id
            @facture.typeImpr = factureold.typeImpr
            @facture.facStatut = factureold.facStatut
            @facture.facDateEmis = factureold.facDateEmis
            @facture.facDelai = factureold.facDelai
            @facture.facDelaiMax = factureold.facDelaiMax
            @facture.facDateLimite = factureold.facDateLimite
            @facture.facDateReception = factureold.facDateReception
            @facture.facRef = factureold.facRef
            @facture.facBdC = factureold.facBdC
            @facture.facRefPre = factureold.facRefPre
            @facture.facProCom = factureold.facProCom
            @facture.facBdcSigne = factureold.facBdcSigne
            @facture.facMention = factureold.facMention
            @facture.facMontBrutHt = factureold.facMontBrutHt
            @facture.facImputProjet = factureold.facImputProjet
            @facture.facImputClient = factureold.facImputClient
            @facture.facMontNetHt = factureold.facMontNetHt
            @facture.facAcomTaux = factureold.facAcomTaux
            @facture.facAcomMont = factureold.facAcomMont
            @facture.facMontTva = factureold.facMontTva
            @facture.facTypeTvaImpot = factureold.facTypeTvaImpot
            @facture.facDeboursTtc = factureold.facDeboursTtc
            @facture.facDeboursTva = factureold.facDeboursTva
            @facture.facDeboursImput = factureold.facDeboursImput
            @facture.facTotalDu = factureold.facTotalDu
            @facture.facReglMont = factureold.facReglMont
            @facture.modePaieLib = factureold.modePaieLib
            @facture.facDifference = factureold.facDifference
            @facture.facLignes = factureold.facLignes
            @facture.facDepass = factureold.facDepass
            @facture.facCourrier = factureold.facCourrier
            @facture.facReA = factureold.facReA
            @facture.projetId = factureold.projetoldId
            @facture.parametreId = factureold.parametreoldId
            begin
                @facture.save
            rescue => e # erreur Facture Create
                @erreurold = Erreurold.new
                @erreurold.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                @erreurold.appli = '1'
                @erreurold.origine = 'Module[ReactivationFactureCreate]: Incident Create Facture - factureold.id=' + factureold.id.to_s
                @erreurold.numLigne = '42'
                @erreurold.message = e.message
                @erreurold.parametreoldId = params[:parametre][:parametreId].to_s
                @erreurold.save
                @erreurReactivation = 1
                break
            end
        end
    end
end