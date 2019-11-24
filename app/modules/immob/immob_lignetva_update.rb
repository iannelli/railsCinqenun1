module ImmobLignetvaUpdate
    ## Modification des lignes de la Déclaration de TVA ******************************
    def immob_lignetva_update_trait
        @arrayImmobId = []
        @ligneArrayImmob = @immob.lignesTva.split("|")
        @resultat = 0
        i = 0
        while i < @ligneArrayImmob.length
            decla = @ligneArrayImmob[i]
            i += 1
            periode = @ligneArrayImmob[i]
            i += 1
            codeLigne = @ligneArrayImmob[i]
            i += 1
            baseHt = @ligneArrayImmob[i].to_i
            i += 1
            tva = @ligneArrayImmob[i].to_i
            i += 1
            @lignetva = Lignetva.where("parametreId = ? AND tvaDecla = ? AND tvaPeriode = ? AND tvaCodeLigne = ?", @paramun.id, decla, periode, codeLigne).first
            if @lignetva.nil?
                @erreur = Erreur.new
                @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                @erreur.appli = "rails - ImmobsController - update"
                @erreur.origine = "erreur Find LigneTva - immob.id=" + params[:id].to_s
                @erreur.numLigne = '462'
                @erreur.message = "@immob.lignesTva = " + @immob.lignesTva.to_s
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