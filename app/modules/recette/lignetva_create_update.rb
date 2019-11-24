module LignetvaCreateUpdate
    # Création/Maj éventuelle des lignes de la Déclaration de TVA
    # Si Franchise TVA[Perte exonération] ou Régime RSI
    def lignetva_create_update_trait
        if @recette.montantHt.to_i < 0 && @recette.montantTva.abs != 0
            @recetteInitiale = Recette.where("parametreId = ? AND facRef = ?", @paramun.id, @recette.facRef).first
            if @recetteInitiale.nil?
                @erreur = Erreur.new
                @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                @erreur.appli = "rails - RecettesController - create - lignetva_create_update_trait"
                @erreur.origine = "erreur Find Recette Initiale à annuler"
                @erreur.numLigne = '79'
                #@erreur.message = e.message
                @erreur.parametreId = params[:parametre][:id].to_s
                @erreur.save
                @CreateOK = 1
            else
                if @paramun.lignetvas.length != 0
                    @paramun.lignetvas.each do |lignetva|
                        @arrayRecetteId = []
                        @arrayRecetteId = lignetva.listeRecetteId.split(",")
                        if @arrayRecetteId.include?(@recetteInitiale.id.to_s)
                            mont = lignetva.tvaBase.to_i + @recette.montantHt.to_i
                            lignetva.tvaBase = mont.to_s
                            mont = lignetva.tvaMontant.to_i + @recette.montantTva.to_i
                            lignetva.tvaMontant = mont.to_s
                            @arrayRecetteId << @recette.id.to_s
                            @arrayRecetteId.uniq! #Unification des id de même valeur en un seul id
                            lignetva.listeRecetteId = @arrayRecetteId.join(',')
                            lignetva.save
                        end
                    end
                end
            end
        end
        if @recette.montantHt.to_i > 0
            @ligneArrayRecette = []
            @ligneArrayRecette = @recette.lignesTva.split("|")
            i = 0
            while i < @ligneArrayRecette.length
                decla = @ligneArrayRecette[i]
                i += 1
                periode = @ligneArrayRecette[i]
                i += 1
                codeLigne = @ligneArrayRecette[i]
                i += 1
                baseHt = @ligneArrayRecette[i].to_i
                i += 1
                tva = @ligneArrayRecette[i].to_i
                i += 1
                @lignetva = Lignetva.where("parametreId = ? AND tvaDecla = ? AND tvaPeriode = ? AND tvaCodeLigne = ?", @paramun.id, decla, periode, codeLigne).first
                if @lignetva.nil?
                    @lignetva = Lignetva.new
                    @lignetva.tvaDecla = decla
                    @lignetva.tvaPeriode = periode
                    @lignetva.tvaCodeLigne = codeLigne
                    @lignetva.tvaBase = baseHt.to_s
                    @lignetva.tvaMontant = tva.to_s
                    @lignetva.listeRecetteId = @recette.id
                    @lignetva.parametreId = @paramun.id
                else
                    calTemp = @lignetva.tvaBase.to_i + baseHt
                    @lignetva.tvaBase = calTemp.to_s
                    calTemp = @lignetva.tvaMontant.to_i + tva
                    @lignetva.tvaMontant = calTemp.to_s
                    @arrayRecetteId = @lignetva.listeRecetteId.split(',')
                    @arrayRecetteId << @recette.id.to_s
                    @arrayRecetteId.uniq! #Unification des id de même valeur en un seul id
                    @lignetva.listeRecetteId = @arrayRecetteId.join(',')
                end
                @lignetva.save
            end
        end
    end
end