module ProjetInactifDepassSeuil
    ## TRAITEMENT DES PROJETS INACTIFS en Dépassement du Seuil de la Franchise
    def projet_inactif_depass_seuil_trait        
        @paramunold.projetolds.each do |projetold|
            @cptFacture = 0
            if projetold.factureolds.length != 0
                projetold.factureolds.each do |factureold|
                    if ['20', '40', '41', '50', '51'].include?(factureold.typeImpr.to_s)
                        if factureold.facStatut.to_s != '3Annulé'
                            anMoisEmission = factureold.facDateEmis.slice(6,4).to_s + factureold.facDateEmis.slice(3,2).to_s
                            if anMoisEmission.to_i >= @parDepassArray[0].to_i
                                if factureold.facMontTva.to_i > 0
                                    factureold.facDepass = '0'
                                    factureold.save
                                else
                                    factureold.facDepass = '1'
                                    factureold.save
                                    @cptFacture += 1
                                end
                            else
                                factureold.facDepass = '0'
                                factureold.save
                            end
                        else
                            factureold.facDepass = '0'
                            factureold.save
                        end
                    end
                end
                if @cptFacture > 0
                    projetold.proDepass = '1'
                    @cptProjetold += 1
                else
                    projetold.proDepass = '0'
                end
                projetold.save
            end                       
        end
    end
end
