module DepenseLignetvaUpdate
    ## Modification des lignes de la Déclaration de TVA ******************************
    def depense_ligneTva_update_trait
        @arrayDepenseId = []
        @ligneArrayDepense = @depense.lignesTva.split("|")
        @resultat = 0
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
                @erreur = Erreur.new
                @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                @erreur.appli = "rails - DepensesController - update"
                @erreur.origine = "erreur Find LigneTva - depense.id=" + params[:id].to_s
                @erreur.numLigne = '306'
                @erreur.message = "@depense.lignesTva = " + @depense.lignesTva.to_s
                @erreur.parametreId = params[:parametre][:id].to_s
                @erreur.save
                @resultat = 2
                break
            else
                calTemp = @lignetva.tvaBase.to_i - baseHt
                @lignetva.tvaBase = calTemp.to_s
                calTemp = @lignetva.tvaMontant.to_i - tva
                @lignetva.tvaMontant = calTemp.to_s
                @lignetva.save
            end
        end
        return @resultat
    end
end