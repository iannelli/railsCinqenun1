module ProjetArchivageCondition
    ## Examen des Conditions d'Archivage du Projet
    def projet_archivage_condition_trait(projet)
        if projet.proReport.to_i == 0
            if projet.taches.length != 0
                regle = 1
                cpt = 0
                projet.taches.each do |tache|
                    if tache.typetacNat.to_s == "FA"
                        cpt += 1
                        if tache.tacStatut == '3miFacturé'
                            @tacFacArray = []
                            @tacFacArray = tache.tacFacString.split('|')
                            i = 2
                            while (i < @tacFacArray.length)
                                if @tacFacArray[i].to_s != 'R'
                                    regle = 0
                                    break
                                else
                                    i += 5
                                end
                            end
                        else
                            if tache.tacStatut != '3Réglé'
                                regle = 0
                                break
                            end
                        end
                    end
                end
                if cpt > 0 && regle == 1
                    projet.proSituation = '22' ## Projet Clos *****
                    @archivageOK = 1
                    @nbreProjetArchiver += 1
                end
            end
        end
        if @archivageOK == 0 # Si Projet 'non Clos' ----------------
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