module LignetvaCreateUpdate
    # Création (y compris écriture négative) des lignes de la Déclaration de TVA
    # Si Franchise TVA[Perte exonération] ou Régime RSI
    def lignetva_create_update_trait       
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
                if @lignetva.listeRecetteId.blank? == false
                    @arrayRecetteId = @lignetva.listeRecetteId.split(',')
                end
                @arrayRecetteId << @recette.id.to_s
                @arrayRecetteId.uniq! #Unification des id de même valeur en un seul id
                @lignetva.listeRecetteId = @arrayRecetteId.join(',')
            end
            @lignetva.save
        end
    end
end