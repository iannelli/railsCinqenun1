module ProjetArchivageProjet
    # Archivage du Projet
    def projet_archivage_projet_trait(projet)
        if projet.proDepass.to_s == '1'
            @cptProjet -= 1
        end
        # Archivage du Projet --------------------------
        @projetold = Projetold.new()
        @projetold.id = projet.id
        @projetold.proLib = projet.proLib
        @projetold.proDateDeb = projet.proDateDeb
        @projetold.proDeadLine = projet.proDeadLine
        @projetold.proSuiviTac = projet.proSuiviTac
        @projetold.proSuiviFac = projet.proSuiviFac
        @projetold.proNumRang = projet.proNumRang
        @projetold.proCliRaisonFacture = projet.proCliRaisonFacture
        @projetold.proCliRaisonProjet = projet.proCliRaisonProjet
        @projetold.proDureeBdc = projet.proDureeBdc
        @projetold.proDureeExec = projet.proDureeExec
        @projetold.proPourExec = projet.proPourExec
        @projetold.proCaHt = projet.proCaHt
        @projetold.proFacHt = projet.proFacHt
        @projetold.proReglMont = projet.proReglMont
        @projetold.proReport = projet.proReport
        @projetold.proCout = projet.proCout
        @projetold.proMarge = projet.proMarge
        @projetold.proSituation = projet.proSituation
        @projetold.proCliString = projet.proCliString
        @projetold.proDepass = projet.proDepass
        @projetold.majDate = projet.majDate
        @projetold.clienteleFactureId = projet.clienteleFactureId
        @projetold.clienteleProjetId = projet.clienteleProjetId
        @projetold.parametreoldId = projet.parametreId
        begin
            @projetold.save
        rescue => e # erreur Projetold Create
            @erreur = Erreur.new
            @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
            @erreur.appli = 'rails - ParamunsController - destroy'
            @erreur.origine = 'Incident Save Projetold - projet.id=' + projet.id.to_s
            @erreur.numLigne = '530'
            @erreur.message = e.message
            @erreur.parametreId = params[:id].to_s
            @erreur.save
            @erreurArchivage = 1
        end   
    end    
end