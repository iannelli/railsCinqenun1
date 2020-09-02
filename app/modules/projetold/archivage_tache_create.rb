module ArchivageTacheCreate
    # Création des Tacheold du Projetold ---
    def archivage_tache_create_trait
        @projet.taches.each do |tache|
            @tacheold = Tacheold.new
            @tacheold.id = tache.id
            @tacheold.famtacNum = tache.famtacNum
            @tacheold.typetacLib = tache.typetacLib
            @tacheold.tacCategorie = tache.tacCategorie
            @tacheold.tacLibCourt = tache.tacLibCourt
            @tacheold.tacLibPeriode = tache.tacLibPeriode
            @tacheold.tacLibDetail = tache.tacLibDetail
            @tacheold.typetacNat = tache.typetacNat
            @tacheold.tacModeFac = tache.tacModeFac
            @tacheold.tacProLib = tache.tacProLib
            @tacheold.tacStatut = tache.tacStatut
            @tacheold.tacCoutHeure = tache.tacCoutHeure
            @tacheold.tacDateDeb = tache.tacDateDeb
            @tacheold.tacDeadLine = tache.tacDeadLine
            @tacheold.tacAchevement = tache.tacAchevement
            @tacheold.tacTravail = tache.tacTravail
            @tacheold.typetacUnite = tache.typetacUnite
            @tacheold.typetacTarifUnite = tache.typetacTarifUnite
            @tacheold.typetacET = tache.typetacET
            @tacheold.tacQuantUnitaire = tache.tacQuantUnitaire
            @tacheold.tacPeriodeNbre = tache.tacPeriodeNbre
            @tacheold.tacQuantTotal = tache.tacQuantTotal
            @tacheold.tacMont = tache.tacMont
            @tacheold.tacRemiseTaux = tache.tacRemiseTaux
            @tacheold.tacBdcHt = tache.tacBdcHt
            @tacheold.tacDureeBdc = tache.tacDureeBdc
            @tacheold.tacFacHt = tache.tacFacHt
            @tacheold.tacDureeExec = tache.tacDureeExec
            @tacheold.tacPourExec = tache.tacPourExec
            @tacheold.tacCout = tache.tacCout
            @tacheold.tacMarge = tache.tacMarge
            @tacheold.tacPeriode = tache.tacPeriode
            @tacheold.projetoldId = tache.projetId
            @tacheold.typetacheId = tache.typetacheId
            @tacheold.parametreoldId = tache.parametreId
            begin
                @tacheold.save
            rescue => e # erreur Tacheold Create
                @erreurold = Erreurold.new
                @erreurold.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                @erreurold.appli = '1'
                @erreurold.origine = 'Module[ArchivageTacheCreate]: Incident Create Tacheold - tache.id=' + tache.id.to_s
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
  