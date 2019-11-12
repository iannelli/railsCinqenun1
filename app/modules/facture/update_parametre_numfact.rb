module UpdateParametreNumfact
    #  FacturesController : MISE A JOUR du dernier Numéro de facture ------------------------------------
    def update_parametre_numfact_trait
        @current_time = DateTime.now
        begin
            @paramun.parNumFact = params[:parametre][:parNumFact].to_s
            @paramun.save
        rescue => e  # Incident Maj Parametre
            @erreur = Erreur.new
            @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
            @erreur.appli = "rails - FacturesController[Create] - ApplicationController[update_parametre_numfact_trait]"
            @erreurCreate = 1         
            @erreur.origine = "erreur Maj Parametre - ApplicationController[update_parametre_numfact_trait]"
            @erreur.numLigne = '10'
            @erreur.message = e.message
            @erreur.parametreId = params[:parametre][:id].to_s
            @erreur.save
        end
    end
end