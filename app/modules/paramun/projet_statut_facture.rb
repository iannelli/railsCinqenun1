module ProjetStatutFacture
    ## MAJ des Suivi des Statuts **FACTURE** et Incidence sur le Projet
    def projet_statut_facture_trait(projet)
        @cptFacture = 0 # décompte des factures en dépassement de franchise
        proSuiviFac = [0,0,0,0]
        projet.factures.each do |facture|
            @majFacture = 0
            if facture.facStatut.slice(0,1) == "3"
                proSuiviFac[3] = 1
            else
                if facture.facStatut.to_s != "3Annulé" && facture.facStatut.to_s != "3Imputé"
                    facDateLimite = DateTime.new(facture.facDateLimite.slice(6,4).to_i, facture.facDateLimite.slice(3,2).to_i, facture.facDateLimite.slice(0,2).to_i)
                    dateMoins15 = facDateLimite - 15
                    if @dateDuJour.strftime("%Y%m%d").to_i > facDateLimite.strftime("%Y%m%d").to_i
                        facture.facStatut[0] = "2"
                        proSuiviFac[2] = 1
                    else
                        if @dateDuJour.strftime("%Y%m%d").to_i >= dateMoins15.strftime("%Y%m%d").to_i
                            facture.facStatut[0] = "1"
                            proSuiviFac[1] = 1
                        else
                            facture.facStatut[0] = "0"
                            proSuiviFac[0] = 1
                        end
                    end
                    @majFacture = 1
                    projet.proSuiviFac = proSuiviFac.join(',')
                    @majProjet = 1
                end
            end
            # Situation de la Facture au regard du Dépassement du Seuil de la Franchise -------
            if @depassOK == 1
                if ['20', '40', '41', '50', '51'].include?(facture.typeImpr.to_s)
                    if facture.facStatut.to_s != '3Annulé'
                        anMoisEmission = facture.facDateEmis.slice(6,4).to_s + facture.facDateEmis.slice(3,2).to_s
                        if anMoisEmission.to_i >= @anMoisDepass.to_i
                            if facture.facMontTva.to_i > 0
                                facture.facDepass = '0'
                                facture.save
                            else
                                facture.facDepass = '1'
                                facture.save
                                @cptFacture += 1
                            end
                        else
                            facture.facDepass = '0'
                            facture.save
                        end
                    else
                        facture.facDepass = '0'
                        facture.save
                    end
                end
            end
            # Maj de la facture
            if @majFacture == 1
                facture.save
            end
        end
    end
end