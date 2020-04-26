module IndexChangementAnnee
    # Traitement de Changement d'année : Ré-Initialisation et Archivage des Recettes/Dépenses/Immobs
    def index_changement_annee_trait
        @majNewAn = '1'
        # parDepass ----
        @paramun.parDepass = "neant,v"
        # parRecette ----------------------------------------
        @parRecetteNewArray = [0,0,0,0,0,0,0]
        @parRecetteOldArray = @paramun.parRecette.split(',')
        @parRecetteNewArray[1] = @parRecetteOldArray[0]
        @parRecetteNewArray[2] = @parRecetteOldArray[1]
        @parRecetteNewArray[3] = @parRecetteOldArray[2]
        @parRecetteNewArray[4] = @parRecetteOldArray[3]
        @parRecetteNewArray[5] = @parRecetteOldArray[4]
        @parRecetteNewArray[6] = @parRecetteOldArray[5]
        @paramun.parRecette = @parRecetteNewArray.join(',')
        # nbreRecette -----
        @nbreRecetteNewArray = [0,0,0,0,0,0,0]
        @nbreRecetteOldArray = @paramun.nbreRecette.split(',')
        @nbreRecetteNewArray[1] = @nbreRecetteOldArray[0]
        @nbreRecetteNewArray[2] = @nbreRecetteOldArray[1]
        @nbreRecetteNewArray[3] = @nbreRecetteOldArray[2]
        @nbreRecetteNewArray[4] = @nbreRecetteOldArray[3]
        @nbreRecetteNewArray[5] = @nbreRecetteOldArray[4]
        @nbreRecetteNewArray[6] = @nbreRecetteOldArray[5]
        @paramun.nbreRecette = @nbreRecetteNewArray.join(',')
        # parDepense ---------------------------------------
        @parDepenseNewArray = [0,0,0,0,0,0,0]
        @parDepenseOldArray = @paramun.parDepense.split(',')
        @parDepenseNewArray[1] = @parDepenseOldArray[0]
        @parDepenseNewArray[2] = @parDepenseOldArray[1]
        @parDepenseNewArray[3] = @parDepenseOldArray[2]
        @parDepenseNewArray[4] = @parDepenseOldArray[3]
        @parDepenseNewArray[5] = @parDepenseOldArray[4]
        @parDepenseNewArray[6] = @parDepenseOldArray[5]
        @paramun.parDepense = @parDepenseNewArray.join(',')
        # nbreDepense -----
        @nbreDepenseNewArray = [0,0,0,0,0,0,0]
        @nbreDepenseOldArray = @paramun.nbreDepense.split(',')
        @nbreDepenseNewArray[1] = @nbreDepenseOldArray[0]
        @nbreDepenseNewArray[2] = @nbreDepenseOldArray[1]
        @nbreDepenseNewArray[3] = @nbreDepenseOldArray[2]
        @nbreDepenseNewArray[4] = @nbreDepenseOldArray[3]
        @nbreDepenseNewArray[5] = @nbreDepenseOldArray[4]
        @nbreDepenseNewArray[6] = @nbreDepenseOldArray[5]
        @paramun.nbreDepense = @nbreDepenseNewArray.join(',')
        # parImmob ---------------------------------------
        @parImmobNewArray = [0,0,0,0,0,0,0]
        @parImmobOldArray = @paramun.parImmob.split(',')
        if @paramun.immobs.length != 0
            @paramun.immobs.each do |immob|
                @imAmorArray = immob.imAmorString.split("|")
                i = 0
                while i < @imAmorArray.length
                    exerImmob = @imAmorArray[i+1].to_i
                    if exerImmob == @anCourant-1
                        parImmob = @parImmobOldArray[0].to_i + @imAmorArray[i+2].to_i
                        @parImmobOldArray[0] = parImmob.to_s
                        break
                    end
                    i += 5
                end
            end
        end
        @parImmobNewArray[1] = @parImmobOldArray[0]
        @parImmobNewArray[2] = @parImmobOldArray[1]
        @parImmobNewArray[3] = @parImmobOldArray[2]
        @parImmobNewArray[4] = @parImmobOldArray[3]
        @parImmobNewArray[5] = @parImmobOldArray[4]
        @parImmobNewArray[6] = @parImmobOldArray[5]
        @paramun.parImmob = @parImmobNewArray.join(',')
        # Archivage des Recettes de l'année N-2 ------------
        if @paramun.recettes.length != 0
            @paramun.recettes.each do |recette|
                if recette.facDateReception.slice(6,4) == @anMoins2.to_s
                    @recetteold = Recetteold.new()
                    @recetteold.id = recette.id
                    @recetteold.facDateEmis = recette.facDateEmis
                    @recetteold.facDateReception = recette.facDateReception
                    @recetteold.facRef = recette.facRef
                    @recetteold.cliRaison = recette.cliRaison
                    @recetteold.proLib = recette.proLib
                    @recetteold.montantHt = recette.montantHt
                    @recetteold.montantTva = recette.montantTva
                    @recetteold.montantTtc = recette.montantTtc
                    @recetteold.montantDebours = recette.montantDebours
                    @recetteold.facReglMont = recette.facReglMont
                    @recetteold.modePaieLib = recette.modePaieLib
                    @recetteold.typeTvaImpot = recette.typeTvaImpot
                    @recetteold.dateEcriture = recette.dateEcriture
                    @recetteold.factureId = recette.factureId
                    @recetteold.parametreoldId = recette.parametreId
                    @recetteold.save
                    recette.destroy
                end
            end
        end
        # Archivage des Depenses de l'année N-2 ----------------
        if @paramun.depenses.length != 0
            @paramun.depenses.each do |depense|
                if depense.dateRegl.slice(6,4) == @anMoins2.to_s
                    @depenseold = Depenseold.new()
                    @depenseold.id = depense.id
                    @depenseold.dateRegl = depense.dateRegl
                    @depenseold.nature = depense.nature
                    @depenseold.libelle = depense.libelle
                    @depenseold.montantFactHt = depense.montantFactHt
                    @depenseold.usagePro = depense.usagePro
                    @depenseold.montantHt = depense.montantHt
                    @depenseold.modeRegl = depense.modeRegl                    
                    @depenseold.refFacture = depense.refFacture
                    @depenseold.fournisseur = depense.fournisseur
                    @depenseold.pays = depense.pays
                    @depenseold.montantTva = depense.montantTva
                    @depenseold.montantTtc = depense.montantTtc
                    @depenseold.tauxTva = depense.tauxTva
                    @depenseold.tauxTvaAutre = depense.tauxTvaAutre
                    @depenseold.typeTvaImpot = depense.typeTvaImpot
                    @depenseold.compteDepense = depense.compteDepense
                    @depenseold.dateEcriture = depense.dateEcriture
                    @depenseold.parametreoldId = depense.parametreId
                    @depenseold.save
                    depense.destroy
                end
            end
        end

        # Maj de parAnFac et parNumFact -----------
        @paramun.parAnFact = @anCourant.to_s
        @paramun.parNumFact = '00000'        
    end
end