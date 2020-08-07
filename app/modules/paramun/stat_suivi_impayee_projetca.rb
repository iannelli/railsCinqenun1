module StatSuiviImpayeeProjetca
   
    def stat_suivi_impayee_projetca_trait
        ## Examen des Projets ------
        @paramun.projets.each do |projet|
            if projet.factures.length != 0
                projet.factures.each do |facture|
                    ## Examen des Devis pour dénombrement et calcul CA
          					if facture.typeImpr.to_s == '10'
                        case projet.proSituation.to_s
                            when '00' # Devis en attente
          								      @arrayDevisEnAttente[0] += 1								  
              								  ca = facture.facMontNetHt.slice(0, facture.facMontNetHt.length-2)
              								  @arrayDevisEnAttente[1] += ca.to_i
                            when '01' # Projet enCours
              								  @arrayProjetEnCours[0] += 1								
              								  ca = facture.facMontNetHt.slice(0, facture.facMontNetHt.length-2)
              								  @arrayProjetEnCours[1] += ca.to_i
                        end
          					end
          					## Examen des Factures impayées
          					if (facture.typeImpr.to_s == '40' || facture.typeImpr.to_s == '41' || facture.typeImpr.to_s == '50' || facture.typeImpr.to_s == '51')
                        if (facture.facStatut.to_s != '3Réglé' && facture.facStatut.to_s != '3Annulé')
                            aaaamm = facture.facDateEmis.slice(6,4) + facture.facDateEmis.slice(3,2)
                            ind = @statFactureAccueilArray.find_index(aaaamm)
                            if ind == nil
                                ind = 18
                            end
                            ind +=1
                            montant1 = @statFactureAccueilArray[ind].to_i
                            montant2 = facture.facTotalDu.to_i / 100
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
            if @nbreProjetArchiver > 0
    		        @nbreProjetClos = 0
            		@paramunold.projetolds.each do |projetold|
                    # Dénombrement Projet clos
              			if projetold.proSituation.to_s == '22'
                        @nbreProjetClos += 1
                    else
                        if projetold.factureolds.length != 0
                            projetold.factureolds.each do |factureold|
                						    ## Examen des Devis pour dénombrement et calcul CA
                								if factureold.typeImpr.to_s == '10'
                                    case projetold.proSituation.to_s
                								        when '20' # Devis en attente Inactif
                                            @arrayDevisInactif[0] += 1
                    						            ca = factureold.facMontNetHt.slice(0, factureold.facMontNetHt.length-2)
                    											  @arrayDevisInactif[1] += ca.to_i
                  										  when '21' # Projet enCours Inactif
                  											    @arrayProjetInactif[0] += 1
                  											    ca = factureold.facMontNetHt.slice(0, factureold.facMontNetHt.length-2)
                                            @arrayProjetInactif[1] += ca.to_i
                  									 end
                								end
                								## Examen des Factures impayées
                								if (factureold.typeImpr.to_s == '40' || factureold.typeImpr.to_s == '41' || factureold.typeImpr.to_s == '50' || factureold.typeImpr.to_s == '51')
                						        if (factureold.facStatut.to_s != '3Réglé' && factureold.facStatut.to_s != '3Annulé')
                                        aaaamm = factureold.facDateEmis.slice(6,4) + factureold.facDateEmis.slice(3,2)
                    										ind = @statFactureAccueilArray.find_index(aaaamm)
                    										if ind == nil
                    										    ind = 18
                    										end
                    										ind +=1
                    										montant1 = @statFactureAccueilArray[ind].to_i
                    										montant2 = factureold.facTotalDu.to_i / 100
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
end