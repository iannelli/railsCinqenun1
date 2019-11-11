module StatSuiviFactureimpayee
    ## Examen des Factures impayées
    def stat_suivi_factureimpayee_trait
        ## Examen des Projets ------
        @paramun.projets.each do |projet|
            if projet.factures.length != 0
                projet.factures.each do |facture|
                    if (facture.typeImpr.to_s == '40' || facture.typeImpr.to_s == '41' || facture.typeImpr.to_s == '50' || facture.typeImpr.to_s == '51')
                        if (facture.facStatut.to_s != '3Réglé' && facture.facStatut.to_s != '3Annulé')
                            aaaamm = facture.facDateEmis.slice(6,4) + facture.facDateEmis.slice(3,2)
                            ind = @statFactureAccueilArray.find_index(aaaamm)
                            if ind == nil
                                ind = 18
                            end
                            ind +=1
                            montant1 = @statFactureAccueilArray[ind].to_i
                            montant2 = facture.facMontHt.to_i / 100
                            @statFactureAccueilArray[ind] = montant1 + montant2.to_i
                            ind +=1
                            nombre = @statFactureAccueilArray[ind].to_i
                            @statFactureAccueilArray[ind] = nombre + 1
                        end
                    end
                end
            end
        end
        ## Examen des Projetolds ------
        if @paramunold.projetolds.length > 0
            @paramunold.projetolds.each do |projetold|
                if projetold.proSituation.to_s != '22'
                    if projetold.factureolds.length != 0
                        projetold.factureolds.each do |factureold|
                            if (factureold.typeImpr.to_s == '40' || factureold.typeImpr.to_s == '41' || factureold.typeImpr.to_s == '50' || factureold.typeImpr.to_s == '51')
                                if (factureold.facStatut.to_s != '3Réglé' && factureold.facStatut.to_s != '3Annulé')
                                    aaaamm = factureold.facDateEmis.slice(6,4) + factureold.facDateEmis.slice(3,2)
                                    ind = @statFactureAccueilArray.find_index(aaaamm)
                                    if ind == nil
                                        ind = 18
                                    end
                                    ind +=1
                                    montant1 = @statFactureAccueilArray[ind].to_i
                                    montant2 = factureold.facMontHt.to_i / 100
                                    @statFactureAccueilArray[ind] = montant1 + montant2.to_i
                                    ind +=1
                                    nombre = @statFactureAccueilArray[ind].to_i
                                    @statFactureAccueilArray[ind] = nombre + 1
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end