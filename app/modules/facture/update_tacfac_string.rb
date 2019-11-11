module UpdateTacfacString
    # FacturesController : MISE A JOUR des Tache.tacFacString et Tache.statut ------------------------------------
    def update_tacfac_string_trait
        t = 0
        # A partir de @tacFacArray (Facture0.paramTacheTacFacString0) MAJ de Tache.tacFacString et de Facture.majTache
        while (t < @tacFacArray.length)
            tacFacElementArray = @tacFacArray[t].split('|')
            e = 0
            while (e < tacFacElementArray.length)
                if params[:operation][:maj] == 'C'
                    if (tacFacElementArray[e+2].to_s == 'F' && tacFacElementArray[e+4].to_s == '.')
                       tacFacElementArray[e+4] = @facture.id
                    end
                    if (tacFacElementArray[e+2].to_s == 'L')
                       tacFacElementArray[e+2] = '.'
                       tacFacElementArray[e+3] = '.'
                       tacFacElementArray[e+4] = '.'
                    end
                end
                if params[:operation][:maj] == 'R'
                    if (tacFacElementArray[e+2].to_s == 'F' && tacFacElementArray[e+4].to_i == @facture.id)
                       tacFacElementArray[e+2] = 'R'
                    end
                end
                if params[:operation][:maj] == 'RImp'
                    if (tacFacElementArray[e+2].to_s == 'F' && tacFacElementArray[e+4].to_i == @facture.id)
                       tacFacElementArray[e+2] = 'I'
                    end
                end
                e += 5
            end
            begin
                @tache = Tache.find(tacFacElementArray[0].to_i)
                totalTacheHt = 0
                nbrePeriodeFacturee = 0 # Nombre de période au Statut "Facturé"
                nbrePeriodeReglee = 0 # Nombre de période au Statut "Réglé" ou "Imputé"
                e = 0
                while (e < tacFacElementArray.length)
                    if tacFacElementArray[e+3] != "." ## montHt
                        totalTacheHt += tacFacElementArray[e+3].to_i
                    end
                    if tacFacElementArray[e+2] == "F"
                        nbrePeriodeFacturee += 1
                    end
                    if tacFacElementArray[e+2] == "R" || tacFacElementArray[e+2] == "I"
                        nbrePeriodeReglee += 1
                    end
                    e += 5
                end
                max = tacFacElementArray.length / 5
                if nbrePeriodeReglee == max
                    @tache.tacStatut = "3Réglé"
                end
                if nbrePeriodeFacturee == max
                    @tache.tacStatut = "3Facturé"
                end
                if nbrePeriodeFacturee > 0 && nbrePeriodeFacturee < max
                    @tache.tacStatut = "3miFacturé"
                end
                if nbrePeriodeFacturee == 0 && nbrePeriodeReglee == 0
                    @tache.tacStatut = "0enCours"
                end
                @tache.tacFacString = tacFacElementArray.join('|')
                @tache.tacFacHt = totalTacheHt
                @tache.tacMarge = totalTacheHt - @tache.tacCout.to_i
                begin
                    @tache.save
                    ## Création de Facture.majTache ------
                    @majTache[@indMajTache] = @tache.id
                    @indMajTache += 1
                    @majTache[@indMajTache] = @tache.tacFacString
                    @indMajTache += 1
                    @majTache[@indMajTache] = @tache.tacStatut
                    @indMajTache += 1
                    @majTache[@indMajTache] = totalTacheHt
                    @indMajTache += 1
                    t += 1
                rescue => e  # Incident Save Tache
                    @erreur = Erreur.new
                    current_time = DateTime.now
                    @erreur.dateHeure = current_time.strftime "%d/%m/%Y %H:%M:%S"
                    if @@origine == 'C'
                        @erreur.appli = "rails - FacturesController - create"
                        @erreurCreate = 1
                    else
                        @erreur.appli = "rails - FacturesController - update"
                        @erreurUpdate = 1
                    end
                    @erreur.origine = "erreur Save Tache - @tache.id=" + @tache.id.to_s
                    @erreur.numLigne = '368'
                    @erreur.message = e.message
                    @erreur.parametreId = params[:parametre][:id].to_s
                    @erreur.save
                    break
                end
            rescue => e  # Incident Find Tache
                @erreur = Erreur.new
                current_time = DateTime.now
                @erreur.dateHeure = current_time.strftime "%d/%m/%Y %H:%M:%S"
                if @@origine == 'C'
                    @erreur.appli = "rails - FacturesController - Create - updateTacFacString"
                    @erreurCreate = 1
                else
                    @erreur.appli = "rails - FacturesController - Update - updateTacFacString"
                    @erreurUpdate = 1
                end
                @erreur.origine = "erreur Find Tache - tacFacElementArray[0]=" + tacFacElementArray[0].to_s
                @erreur.numLigne = '334'
                @erreur.message = e.message
                @erreur.parametreId = params[:parametre][:id].to_s
                @erreur.save
                break
            end
        end ## end while ---
    end
end