module ImmobLignetvaCreate
    ## Création des lignes de la Déclaration de TVA ******************************
    def immob_ligneTva_create_trait
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
                @lignetva = Lignetva.new
                @lignetva.tvaDecla = decla
                @lignetva.tvaPeriode = periode
                @lignetva.tvaCodeLigne = codeLigne
                @lignetva.tvaBase = baseHt.to_s
                @lignetva.tvaMontant = tva.to_s
                @lignetva.listeImmobId = @immob.id
                @lignetva.parametreId = @paramun.id
            else
                calTemp = @lignetva.tvaBase.to_i + baseHt
                @lignetva.tvaBase = calTemp.to_s
                calTemp = @lignetva.tvaMontant.to_i + tva
                @lignetva.tvaMontant = calTemp.to_s 
                @arrayImmobId = @lignetva.listeImmobId.split(',')
                @arrayImmobId << @immob.id.to_s
                @arrayImmobId.uniq! #Unification des id de même valeur en un seul id
                @lignetva.listeImmobId = @arrayImmobId.join(',')
            end
            begin
                @lignetva.save
            rescue => e # Incident create/update Lignetva
                @erreur = Erreur.new
                @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                @erreur.appli = "rails - ImmobsController - creationLigneTva"
                @erreur.origine = "erreur create/update Lignetva"
                @erreur.numLigne = '406'
                @erreur.message = e.message
                @erreur.parametreId = params[:parametre][:id].to_s
                @erreur.save
                @resultat = 2
            end
            return @resultat
        end
    end
end