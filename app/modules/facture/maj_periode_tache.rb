module MajPeriodeTache
    ## Mise à jour éventuelle de période de tache(tacFacString) avant de débuter le traitement de facturation
    def maj_periode_tache_trait
        t = 0
        while (t < @tacFacArray.length)
            tacFacElementArray = @tacFacArray[t].split('|')
            begin
                @tache = Tache.find(tacFacElementArray[0].to_i)
                @tache.tacFacString = @tacFacArray[t].to_s
                begin
                    @tache.save
                    t += 1
                rescue => e  # Incident MAJ Tache
                    @erreur = Erreur.new
                    @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                    @erreur.appli = "rails - FacturesController - create"
                    @erreur.origine = "erreur Maj Periode tache - @tache.id=" + @tache.id.to_s
                    @erreur.numLigne = '89'
                    @erreur.message = e.message
                    @erreur.parametreId = params[:parametre][:id].to_s
                    @erreur.save
                    @erreurCreate = 1
                    break
                end
            rescue => e  # Incident Find Tache
                @erreur = Erreur.new
                @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                @erreur.appli = "rails - FacturesController - create"
                @erreur.origine = "erreur Maj Find tache - tacFacElementArray=" + tacFacElementArray.to_s
                @erreur.numLigne = '86'
                @erreur.message = e.message
                @erreur.parametreId = params[:parametre][:id].to_s
                @erreur.save
                @erreurCreate = 1
                break
            end
        end
    end
end