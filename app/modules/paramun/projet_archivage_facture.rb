module ProjetArchivageFacture
    # Archivage des Factures en Facturesold
    def projet_archivage_facture_trait(projet)
        projet.factures.each do |facture|
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
            @factureold.facMontHt = facture.facMontHt
            @factureold.facMontTva = facture.facMontTva
            @factureold.facMontTtc = facture.facMontTtc
            @factureold.facAcomTaux = facture.facAcomTaux
            @factureold.facAcomMont = facture.facAcomMont
            @factureold.facImputProjet = facture.facImputProjet
            @factureold.facImputClient = facture.facImputClient
            @factureold.facDifference = facture.facDifference
            @factureold.facTotalDu = facture.facTotalDu
            @factureold.modePaieLib = facture.modePaieLib
            @factureold.facReglMont = facture.facReglMont
            @factureold.facStringLigne = facture.facStringLigne
            @factureold.majTache = facture.majTache
            @factureold.facDepass = facture.facDepass
            @factureold.facTypeDecla = facture.facTypeDecla
            @factureold.facCourrier = facture.facCourrier
            @factureold.facReA = facture.facReA
            @factureold.projetoldId = facture.projetId
            @factureold.parametreoldId = facture.parametreId
            begin
                @factureold.save
            rescue => e # erreur Factureold Create
                @erreur = Erreur.new
                @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                @erreur.appli = 'rails - ParamunsController - destroy'
                @erreur.origine = 'Incident Save Factureold - facture.id=' + facture.id.to_s
                @erreur.numLigne = '637'
                @erreur.message = e.message
                @erreur.parametreId = params[:id].to_s
                @erreur.save
                @erreurArchivage = 1
                break
            end
        end
    end
end