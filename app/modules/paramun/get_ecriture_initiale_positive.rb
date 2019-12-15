module GetEcritureInitialePositive
    ## Recherche de l'Ecriture initiale positive correspondante à l'Ecriture négative examinée
    def get_ecriture_initiale_positive_trait(recette)
        @aaaammRecette = recette.facDateReception.slice(6,4) + recette.facDateReception.slice(3,2)
        montantHtVA = recette.montantHt.to_i * -1
        @paramun.recettes.each do |recette2|
            if (recette2.facDateEmis.to_s == recette.facDateEmis.to_s && recette2.cliRaison.to_s == recette.cliRaison.to_s &&               
                recette2.proLib.to_s == recette.proLib.to_s && recette2.montantHt.to_s == montantHtVA.to_s)
                @aaaammRecette = recette.facDateEmis.slice(6,4) + recette.facDateEmis.slice(3,2)
                break
            end
        end
    end
end