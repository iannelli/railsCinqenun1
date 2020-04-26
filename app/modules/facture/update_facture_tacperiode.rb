module UpdateFactureTacperiode
    # FacturesController : MISE A JOUR des Tache.tacPeriode et Tache.statut ------------------------------------
    def update_facture_tacperiode_trait
        arrayIdTache = []
        facLignesArray = @facture.facLignes.split('|')
        f = 0

        # A partir de facLigneArray, MAJ de Tache.tacPeriode
        while (f < facLignesArray.length)
            facPeriodeTacheArray = facLignesArray[f].split('*')
            if facPeriodeTacheArray[0].to_s != "débours"
                begin
                    @tache = Tache.find(facPeriodeTacheArray[0].to_i)
                    tacPeriodeArray = @tache.tacPeriode.split('|')
                    p = 0
                    while (p < tacPeriodeArray.length)
                        if tacPeriodeArray[p].to_s == facPeriodeTacheArray[1].to_s
                            if params[:operation][:maj] == 'C'
                                if facPeriodeTacheArray[2].to_s == 'F'
                                    tacPeriodeArray[p+1] = 'F'
                                    tacPeriodeArray[p+2] = facPeriodeTacheArray[3].to_s
                                    tacPeriodeArray[p+3] = @facture.id
                                    facLignesArray[f] = facPeriodeTacheArray.join('*')
                                    @facture.facLignes = facLignesArray.join('|')
                                    @facture.save
                                end
                                if (facPeriodeTacheArray[2].to_s == 'L')
                                    tacPeriodeArray[p+1] = 'L'
                                    tacPeriodeArray[p+2] = '.'
                                    tacPeriodeArray[p+3] = '.'
                                end
                                @tache.tacPeriode = tacPeriodeArray.join('|')
                                arrayIdTache << @tache.id.to_s
                                arrayIdTache.uniq! #Unification des id de même valeur en un seul id
                                @tache.save
                                break
                            end
                            if params[:operation][:maj] == 'R' || params[:operation][:maj] == 'RRep'
                                if tacPeriodeArray[p+1].to_s == 'F'
                                    tacPeriodeArray[p+1] = 'R'
                                end
                                @tache.tacPeriode = tacPeriodeArray.join('|')
                                arrayIdTache << @tache.id.to_s
                                arrayIdTache.uniq! #Unification des id de même valeur en un seul id
                                @tache.save
                                break
                            end
                        end
                        p += 4
                    end
                rescue => e  # Incident Find Tache
                    @erreur = Erreur.new
                    current_time = DateTime.now
                    @erreur.dateHeure = current_time.strftime "%d/%m/%Y %H:%M:%S"
                    if @origine == 'C'
                        @erreur.appli = "rails - FacturesController - Create - UpdateFactureTacperiode"
                        @erreurCreate = 1
                    else
                        @erreur.appli = "rails - FacturesController - Update - UpdateFactureTacperiode"
                        @erreurUpdate = 1
                    end
                    @erreur.origine = "erreur Find Tache - facPeriodeTacheArray[0]=" + facPeriodeTacheArray[0].to_s
                    @erreur.numLigne = '13'
                    @erreur.message = e.message
                    @erreur.parametreId = params[:parametre][:id].to_s
                    @erreur.save
                    break
                end
            end
            f += 11
        end ## end while (f < facLignesArray  ---

        # Maj de Tache.tacStatut ----
        if ( (@origine == 'C' && @erreurCreate == 0) || (@origine == 'U' && @erreurUpdate == 0) )
            arrayIdTache.each { |id|
                @tache = Tache.find(id.to_i)
                tacPeriodeArray = @tache.tacPeriode.split('|')
                p = 0
                totalTacheHt = 0
                nbrePeriodeFacturee = 0 # Nombre de période au Statut "Facturé"
                nbrePeriodeReglee = 0 # Nombre de période au Statut "Réglé" ou "Imputé"
                while (p < tacPeriodeArray.length)
                    if tacPeriodeArray[p+2] != "."## montHt
                        totalTacheHt += tacPeriodeArray[p+2].to_i
                    end
                    if tacPeriodeArray[p+1] == "F"
                        nbrePeriodeFacturee += 1
                    end
                    if tacPeriodeArray[p+1] == "R"
                        nbrePeriodeReglee += 1
                    end
                    p += 4
                end
                max = tacPeriodeArray.length / 4
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
                @tache.tacFacHt = totalTacheHt
                @tache.tacMarge = totalTacheHt - @tache.tacCout.to_i
                @tache.save
            }
        end
    end
end