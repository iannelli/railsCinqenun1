module DepenseLignetvaCreate
    ## Création des lignes de la Déclaration de TVA ******************************
    def depense_lignetva_create_trait
        @arrayDepenseId = []
        @ligneArrayDepense = @depense.lignesTva.split("|")
        i = 0
        while i < @ligneArrayDepense.length
            decla = @ligneArrayDepense[i]
            i += 1
            periode = @ligneArrayDepense[i]
            i += 1
            codeLigne = @ligneArrayDepense[i]
            i += 1
            baseHt = @ligneArrayDepense[i].to_i
            i += 1
            tva = @ligneArrayDepense[i].to_i
            i += 1
            @lignetva = Lignetva.where("parametreId = ? AND tvaDecla = ? AND tvaPeriode = ? AND tvaCodeLigne = ?", @paramun.id, decla, periode, codeLigne).first
            if @lignetva.nil?
                @lignetva = Lignetva.new
                @lignetva.tvaDecla = decla
                @lignetva.tvaPeriode = periode
                @lignetva.tvaCodeLigne = codeLigne
                @lignetva.tvaBase = baseHt.to_s
                @lignetva.tvaMontant = tva.to_s
                @lignetva.listeDepenseId = @depense.id
                @lignetva.parametreId = @paramun.id
            else
                calTemp = @lignetva.tvaBase.to_i + baseHt
                @lignetva.tvaBase = calTemp.to_s
                calTemp = @lignetva.tvaMontant.to_i + tva
                @lignetva.tvaMontant = calTemp.to_s 
                @arrayDepenseId = @lignetva.listeDepenseId.split(',')
                @arrayDepenseId << @depense.id.to_s
                @arrayDepenseId.uniq! #Unification des id de même valeur en un seul id
                @lignetva.listeDepenseId = @arrayDepenseId.join(',')
            end
            @lignetva.save
        end
    end
end