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
            @erreur.appli = "1"
            @erreurCreate = 1         
            @erreur.origine = "Module[update_parametre_numfact_trait]: erreur Maj Parametre.parNumFact"
            @erreur.numLigne = '7'
            @erreur.message = e.message
            @erreur.parametreId = params[:parametre][:id].to_s
            @erreur.save
        end
    end
end