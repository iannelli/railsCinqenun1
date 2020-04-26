module ProjetArchivageCondition
    ## Examen des Conditions d'Archivage du Projet ------
    def projet_archivage_condition_trait(projet)
        if projet.proReportFacture.to_i == 0 && projet.proReportDebours.to_i == 0
            # Examen de la Situation des Factures du Projet ----
            projet.factures.each do |facture|
                if (facture.typeImpr.to_s == '40' || facture.typeImpr.to_s == '41' ||
                    facture.typeImpr.to_s == '50' || facture.typeImpr.to_s == '51')
                    if facture.facStatut.to_s == "3Réglé" || facture.facStatut.to_s == "3Reporté"
                        if facture.facReA.blank? == true
                            @archivageOK = 1
                            break 
                        else
                           @archivageOK = 1
                           @arrayReA = facture.facReA.split('')
                           if @arrayReA[3].to_s == "en attente"
                              @archivageOK = 0
                              break
                           end 
                        end
                    else
                        @archivageOK = 0
                        break
                    end
                end
            end
            # Examen de la Situation des Tâches du Projet ------
            if @archivageOK == 1
                if projet.taches.length != 0
                    projet.taches.each do |tache|
                        if tache.typetacNat.to_s == "FA"
                            if tache.tacStatut.to_s != '3Réglé'
                                @archivageOK = 0
                                break
                            end
                        end
                    end
                end
            end
            # Situation Finale -----
            if @archivageOK == 1
                projet.proSituation = '22' ## Projet Clos *****
                @nbreProjetArchiver += 1
            end
        end

        # Si Projet 'non Clos' ----------------
        if @archivageOK == 0
            t = Time.now
            dateJour = t.strftime("%d") + '/' + t.strftime("%m") + '/' + t.strftime("%Y")
            @dateDuJour = Date.parse(dateJour)
            majDate = Date.parse(projet.majDate.to_s)
            dureeJ = @dateDuJour - majDate
            if dureeJ.to_i  > 180 ## Si 'projet 'Inactif' depuis +6mois ----
                situation = '2' + projet.proSituation.slice(1,1)
                projet.proSituation = situation ## Devis EnAttente Inactif ou Projet enCours Inactif ****
                @archivageOK = 1
                @nbreProjetArchiver += 1
            end
        end
    end
end