module ProjetArchivageTache
    # Archivage des Taches en Tachesold
    def projet_archivage_tache_trait(projet)
        projet.taches.each do |tache|
            # Vérification présence de TacheOld
            @tacheold1 = Tacheold.where("id = ?", tache.id).first
            unless @tacheold1.nil? # Suppression de la Tacheold
                @tacheold1.destroy
            end
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
            rescue => e # erreur Tacheold Save
                @erreur = Erreur.new
                @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                @erreur.appli = '1'
                @erreur.origine = 'Module[ProjetArchivageTache]: Incident Create Tacheold - tache.id=' + tache.id.to_s
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