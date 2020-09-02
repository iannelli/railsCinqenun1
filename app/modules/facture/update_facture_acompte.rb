module UpdateFactureAcompte
    ## FacturesController : Mise à jour du mode de Règlement de la Facture d'Acompte ------------------------------------
    def update_facture_acompte_trait
        begin
            @factureAcompte = Facture.find(@factureAcompteArray[1].to_i)
            @factureAcompte.modePaieLib = @factureAcompteArray[3].to_s
            @factureAcompte.save
        rescue => e  # Incident Maj Facture
            @erreur = Erreur.new
            @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
            @erreur.appli = "1"
            @erreur.origine = "Module[UpdateFactureAcompte]: erreur Find Facture.id=@factureAcompteArray[1].to_i " + @factureAcompteArray[1].to_s
            @erreur.numLigne = '5'
            @erreur.message = e.message
            @erreur.parametreId = params[:parametre][:id].to_s
            @erreur.save
            @erreurUpdate = 2
        end
        if @erreurUpdate == 0 ## Fin du Traitement --------------------
            @erreurUpdate = 4
        end
    end
end