module UpdateTacheTacperiode
    # Application des Modifications des Tache.tacPeriode générées (éventuellement) lors de la Création de la Facture par Cinqenun[TWTachesFacture.mxml] ------------------------------------
    # (Tache périodique uniquement)
    def update_tache_tacperiode_trait
        pa = 0
        while (pa < @paramMajTacPeriodeArray.length)
            elementParamArray = @paramMajTacPeriodeArray[pa].split('*')
            ep = 0
            begin
                @tache = Tache.find(elementParamArray[ep].to_i) # ep = 0 (tache.id)
                ep += 1
                tacPeriodeArray = @tache.tacPeriode.split('|')
                p = 0
                while (p < tacPeriodeArray.length)
                    tacPeriodeArray[p] = elementParamArray[ep].to_s
                    ep += 1
                    p += 4
                end
                @tache.tacPeriode = tacPeriodeArray.join('|')
                @tache.save
            rescue => e  # Incident Find Tache
                @erreur = Erreur.new
                current_time = DateTime.now
                @erreur.dateHeure = current_time.strftime "%d/%m/%Y %H:%M:%S"
                @erreur.appli = "rails - FacturesController - Create - updateTacPeriode"
                @erreur.origine = "erreur Find Tache - facPeriodeTacheArray[0]=" + facPeriodeTacheArray[0].to_s
                @erreur.numLigne = '13'
                @erreur.message = e.message
                @erreur.parametreId = params[:parametre][:id].to_s
                @erreur.save
                break
            end
            pa += 1
        end # end while (pa < @paramMajTacPeriodeArray
    end
end
