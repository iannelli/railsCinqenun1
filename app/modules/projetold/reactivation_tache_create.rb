module ReactivationTacheCreate
    # Création des Taches du Projet Réactivé ---
    def reactivation_tache_create_trait
        @projetold.tacheolds.each do |tacheold|
            @tache = Tache.new
            @tache.id = tacheold.id
            @tache.famtacNum = tacheold.famtacNum
            @tache.typetacLib = tacheold.typetacLib
            @tache.tacCategorie = tacheold.tacCategorie
            @tache.tacLibCourt = tacheold.tacLibCourt
            @tache.tacLibPeriode = tacheold.tacLibPeriode
            @tache.tacLibDetail = tacheold.tacLibDetail
            @tache.typetacNat = tacheold.typetacNat
            @tache.tacModeFac = tacheold.tacModeFac
            @tache.tacProLib = tacheold.tacProLib
            @tache.tacStatut = tacheold.tacStatut
            @tache.tacCoutHeure = tacheold.tacCoutHeure
            @tache.tacDateDeb = tacheold.tacDateDeb
            @tache.tacDeadLine = tacheold.tacDeadLine
            @tache.tacAchevement = tacheold.tacAchevement
            @tache.tacTravail = tacheold.tacTravail
            @tache.typetacUnite = tacheold.typetacUnite
            @tache.typetacTarifUnite = tacheold.typetacTarifUnite
            @tache.typetacET = tacheold.typetacET
            @tache.tacQuantUnitaire = tacheold.tacQuantUnitaire
            @tache.tacPeriodeNbre = tacheold.tacPeriodeNbre
            @tache.tacQuantTotal = tacheold.tacQuantTotal
            @tache.tacMont = tacheold.tacMont
            @tache.tacRemiseTaux = tacheold.tacRemiseTaux
            @tache.tacBdcHt = tacheold.tacBdcHt
            @tache.tacDureeBdc = tacheold.tacDureeBdc
            @tache.tacFacHt = tacheold.tacFacHt
            @tache.tacDureeExec = tacheold.tacDureeExec
            @tache.tacPourExec = tacheold.tacPourExec
            @tache.tacCout = tacheold.tacCout
            @tache.tacMarge = tacheold.tacMarge
            @tache.tacPeriode = tacheold.tacPeriode
            @tache.projetId = tacheold.projetoldId
            @tache.typetacheId = tacheold.typetacheId
            @tache.parametreId = tacheold.parametreoldId
            begin
                @tache.save
            rescue => e # erreur Tache Create
                @erreurold = Erreurold.new
                @erreurold.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                @erreurold.appli = '1'
                @erreurold.origine = 'Module[ReactivationTacheCreate]: Incident Create Tache - tacheold.id=' + tacheold.id.to_s
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