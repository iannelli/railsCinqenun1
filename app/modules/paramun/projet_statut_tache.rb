module ProjetStatutTache
    ## MAJ des Suivi des Statuts **TACHE** et Incidence sur le Projet ---------------
    def projet_statut_tache_trait(projet)
        proSuiviTac = [0,0,0,0]
        projet.taches.each do |tache|
            if tache.typetacNat.to_s == "FA"
                if tache.tacStatut.slice(0,1) == "3"
                    proSuiviTac[3] = 1
                else
                    tacDeadLine = DateTime.new(tache.tacDeadLine.slice(6,4).to_i, tache.tacDeadLine.slice(3,2).to_i, tache.tacDeadLine.slice(0,2).to_i)
                    dateMoins15 = tacDeadLine - 15
                    if @dateDuJour.strftime("%Y%m%d").to_i > tacDeadLine.strftime("%Y%m%d").to_i
                        tache.tacStatut[0] = "2"
                        proSuiviTac[2] = 1
                    else
                        if @dateDuJour.strftime("%Y%m%d").to_i >= dateMoins15.strftime("%Y%m%d").to_i
                            tache.tacStatut[0] = "1"
                            proSuiviTac[1] = 1
                        else
                            tache.tacStatut[0] = "0"
                            proSuiviTac[0] = 1
                        end
                    end
                    tache.save
                end
                projet.proSuiviTac = proSuiviTac.join(',')
                @majProjet = 1
            end
        end
    end
end