class ParamunsController < ApplicationController
  # VERIFICATION de la Connexion *******************
  before_action :authenticate_rights, :except => [:index, :create, :destroy]

  def authenticate_rights
      dateConnex = params[:parametre][:parDateConnex]
      @paramun = Paramun.find(params[:parametre][:id].to_i)

      if dateConnex.to_i > @paramun.parDateConnex.to_i
          respond_to do |format|
              format.xml { render request.format.to_sym => "pparErreurS" }
          end
      end
  end


  # GET /parametres ****** CHARGEMENT ************************
  def index
      #@paramuns = Paramun.all
      @indexOK = 0
      @current_time = DateTime.now
      @majNewAn = '0'
      begin
          @paramun = Paramun.find(params[:parametre][:id])
          @anCourant = Time.new.year
          @anMoins2 = @anCourant - 2
          # Traitement de Changement d'année : Ré-Initialisation et Archivage des Recettes/Dépenses/Immobs
          if @anCourant > @paramun.parDateConnex.slice(0,4).to_i
              index_changement_annee_trait
          end
          # Maj parNouvelAn (changement d'Année) ----
          @paramun.parNouvelAn = @majNewAn
          # Maj de parDateConnex -----------
          @paramun.parDateConnex = (@current_time.strftime "%Y%m%d%H%M%S").to_s #Date-Heure Connexion 'aaaammjjhhmnss'
          @paramun.save
      rescue => e # Incident Find de Paramun
          @erreur = Erreur.new
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = "rails - ParamunsController - index"
          @erreur.origine = "erreur Find Paramun - params[:parametre][:id]=" + params[:parametre][:id].to_s
          @erreur.numLigne = '24'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:id].to_i
          @erreur.save
          @indexOK = 1
      end
      respond_to do |format|
          case @indexOK
              when 0
                  format.xml  { render xml: @paramun }
              when 1
                  format.xml { render request.format.to_sym => "pparErreurI" } # Incident Find Paramun
          end
      end
  end


  # POST /paramuns ********* CREATE ***************************************
  # POST /paramuns.xml
  def create
      @current_time = DateTime.now
      @createOK = 0
      @paramun = Paramun.new(paramun_params)
      begin
          @paramun.save
      rescue => e
          @erreur = Erreur.new
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = 'rails - ParamunsController - create'
          @erreur.origine = 'Erreur Create Paramun'
          @erreur.numLigne = '67'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:id].to_s
          @erreur.save
          @createOK = 1
      end
      if @createOK == 0
          begin
              @abonne = Abonne.find(@paramun.abonneId.to_i)
              @abonne.aboMajPar = 'U'
              @abonne.parametreId = @paramun.id    
              @abonne.save
          rescue => e # Incident Save Paramun
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = "rails - ParamunsController - create"
              @erreur.origine = "erreur update Abonne - @abonne.id=" + @paramun.abonneId.to_s
              @erreur.numLigne = '80'
              @erreur.message = e.message
              @erreur.parametreId = params[:id].to_s
              @erreur.save
              @createOK = 2
          end
      end
      respond_to do |format|
        if @createOK == 0
          format.xml { render xml: @paramun }
        else
          format.xml { render request.format.to_sym => "pparErreurC" }
        end
      end
  end


  # PATCH/PUT /paramuns/1
  # PATCH/PUT /paramuns/1.json
  def update
      @updateOK = 0
      @current_time = DateTime.now
      # Mise à jour des Données Parametre et Identification Abonne -------
      if params[:typeMaj][:maj].to_s == 'UParAbonne'
          if params[:typeMaj][:par].to_s == '1'
              begin
                  @paramun.update(paramun_params)
                  @updateOK += 10 # @updateOK = 10
              rescue => e # Incident Save Paramun
                  @erreur = Erreur.new
                  @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                  @erreur.appli = "rails - ParamunsController - update"
                  @erreur.origine = "erreur update Paramun - @paramun.id=" + params[:id].to_s
                  @erreur.numLigne = '70'
                  @erreur.message = e.message
                  @erreur.parametreId = params[:id].to_s
                  @erreur.save
                  @updateOK = 2 # @updateOK = 2
              end
          end
          if @updateOK != 2
              if params[:typeMaj][:abo].to_s == '1'
                  @abonne = Abonne.find(@paramun.abonneId)
                  @abonne.aboIden = params[:abonne][:aboIden].to_s
                  @abonne.aboSeuilBase = params[:abonne][:seuilBase].to_s
                  @abonne.aboSeuilMajo = params[:abonne][:seuilMajo].to_s
                  begin
                      @abonne.save
                      @updateOK += 10 # @updateOK = 10 ou 20
                  rescue => e # Incident Save Paramun
                      @erreur = Erreur.new
                      @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                      @erreur.appli = "rails - ParamunsController - update"
                      @erreur.origine = "erreur update Abonne - @abonne.id=" + params[:id].to_s
                      @erreur.numLigne = '92'
                      @erreur.message = e.message
                      @erreur.parametreId = params[:id].to_s
                      @erreur.save
                      @updateOK = 3
                  end
              end
          end
          respond_to do |format|
              case @updateOK
                  when 2
                      format.xml { render request.format.to_sym => "pparErreurU2" }
                  when 3
                      format.xml { render request.format.to_sym => "pparErreurU3" }
                  when 10
                      format.xml { render request.format.to_sym => "pparametreOK10" }
                  when 20
                      format.xml { render request.format.to_sym => "pparametreOK20" }
              end
          end
      end
      # Mise à jour des Données de la FranchiseTVA suite à l'Ouverture de Cinqenun  ---------------
      if params[:typeMaj][:maj].to_s == 'UParFranchiseOuverture'
          begin
              @paramun.update(paramun_params)
          rescue => e # Incident Save Paramun
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = "rails - ParamunsController - update"
              @erreur.origine = "erreur update Paramun - @paramun.id=" + params[:id].to_s
              @erreur.numLigne = '122'
              @erreur.message = e.message
              @erreur.parametreId = params[:id].to_s
              @erreur.save
              @updateOK = 1
          end
          if @updateOK == 0
              @abonne = Abonne.find(@paramun.abonneId.to_i)
              @abonne.aboSeuilBase = params[:abonne][:seuilBase].to_s
              @abonne.aboSeuilMajo = params[:abonne][:seuilMajo].to_s
              begin
                  @abonne.save
              rescue => e # Incident Save Paramun
                  @erreur = Erreur.new
                  @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                  @erreur.appli = "rails - ParamunsController - update"
                  @erreur.origine = "erreur update Abonne - @abonne.id=" + params[:id].to_s
                  @erreur.numLigne = '139'
                  @erreur.message = e.message
                  @erreur.parametreId = params[:id].to_s
                  @erreur.save
                  @updateOK = 2
              end
          end
          respond_to do |format|
              case @updateOK
                  when 0
                      format.xml { render request.format.to_sym => "pparametreOKFra" }
                  when 1, 2
                      format.xml { render request.format.to_sym => "pparErreurU2" }
              end
          end
      end
      # Mise à jour des Données de la FranchiseTVA suite à la saisie du Règlement d'une Facture  ---------------
      if params[:typeMaj][:maj].to_s == 'UParFranchiseImposition'
          begin
              @paramun.update(paramun_params)
          rescue => e # Incident Save Paramun
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = "rails - ParamunsController - update"
              @erreur.origine = "erreur update Paramun - @paramun.id=" + params[:id].to_s
              @erreur.numLigne = '164'
              @erreur.message = e.message
              @erreur.parametreId = params[:id].to_s
              @erreur.save
              @updateOK = 1
          end
          respond_to do |format|
              case @updateOK
                  when 0
                      format.xml { render request.format.to_sym => "pparametreOKFra" }
                  when 1
                      format.xml { render request.format.to_sym => "pparErreurU3" }
              end
          end
      end
  end




  # DELETE /paramuns/1
  # DELETE /paramuns/1.json
  def destroy
      @dateDuJour = Time.now
      @current_time = Time.now
      @majParamun = 0
      @cptProjet = 0 # décompte des projets Actifs en dépassement de franchise
      @cptProjetold = 0 # décompte des projets InActifs en dépassement de franchise
      @aaaammRecette = ''
      ## Si Déconnexion de l'Application ######################################
      if params[:parametre][:maj] == 'DA'
          @erreurArchivage = 0
          @archivageOK = 0
          @nbreProjetArchiver = 0
          ## Examen des Conditions de Dépassement de la Franchise TVA -----------
          @paramun = Paramun.find(params[:id])
          @parDepassArray = @paramun.parDepass.split(",")
          @depassOK = 0
          if @parDepassArray[0].to_s != 'neant'
              if @parDepassArray[1].to_s == 'v'
                  @depassOK = 1
              else 
                  if @parDepassArray[1].to_i > 0
                       @depassOK = 1
                  end
              end
          end
          # Find de @paramunold (ou création si 1ère fois) ----
          @paramunold = Paramunold.where(["id = ?", params[:id].to_i]).first
          if @paramunold.nil?          
              @paramunold = Paramunold.new()
              @paramunold.id = @paramun.id
              @paramunold.save
          end
          ## TRAITEMENT DES PROJETS ACTIFS **************************
          if @paramun.projets.length != 0
              ## Examen des Projets ----------
              @paramun.projets.each do |projet|
                  #@projet = projet
                  @archivageOK = 0
                  @majProjet = 0
                  ## Tâche : Suivi de leurs Statuts et Incidence sur le Projet -----
                  if projet.taches.length != 0
                      projet_statut_tache_trait(projet)
                  end

                  ## Facture : suivi de leurs Statuts et Examen au regard du Dépassement du Seuil de la Franchise
                  ## et Incidence sur le Projet ------
                  @cptFacture = 0
                  if projet.factures.length != 0
                      projet_statut_facture_trait(projet)
                  end

                  # Situation du Projet au regard du Dépassement du Seuil de la Franchise ----
                  if @depassOK == 1
                      if @cptFacture > 0
                          projet.proDepass = '1'
                          @cptProjet += 1
                      else
                          projet.proDepass = '0'
                      end
                      @majProjet = 1
                  end
                  ## MAJ éventuelle de l'occurrence de Projet ---------
                  if @majProjet == 1
                      begin
                          projet.save
                      rescue => e  # erreur Save Projet
                          @erreur = Erreur.new
                          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                          @erreur.appli = "rails - ProjetsController - index"
                          @erreur.origine = "erreur Save Projet - projet.id=" + projet.id.to_s
                          @erreur.numLigne = '256'
                          @erreur.message = e.message
                          @erreur.parametreId = params[:id].to_s
                          @erreur.save
                          @erreurSaveProjet = 1
                      end
                  end
                  ## Examen des Conditions d'Archivage du Projet --------------------------
                  @archivageOK = 0
                  if projet.proDepass.to_s == '0'
                      projet_archivage_condition_trait(projet)
                  end
                  ## Si Archivage OK -------------------
                  if @archivageOK == 1
                      # Archivage du Projet en ProjetOld
                      projet_archivage_projet_trait(projet)
                      # Archivage des Taches en Tachesold
                      if @erreurArchivage == 0
                          if projet.taches.length != 0
                              projet_archivage_tache_trait(projet)
                          end
                      end
                      # Archivage des Factures en Facturesold
                      if @erreurArchivage == 0
                          if projet.factures.length != 0
                              projet_archivage_facture_trait(projet)
                          end
                      end
                      # Suppression des Tache du Projet ---
                      if @erreurArchivage == 0
                          if projet.taches.length != 0
                              projet.taches.each do |tache|
                                  begin
                                      tache.destroy
                                  rescue => e  # Incident destroy Tache
                                      @erreur = Erreur.new
                                      @erreurdateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                                      @erreur.appli = 'rails - ParamunsController - destroy'
                                      @erreur.origine = "erreur destroy Tache - tache.id =" + tache.id.to_s
                                      @erreur.numLigne = '295'
                                      @erreur.message = e.message
                                      @erreur.parametreId = params[:id].to_s
                                      @erreur.save
                                      @erreurArchivage = 1
                                  end
                              end
                          end
                      end
                      # Suppression des Facture du Projet ---
                      if @erreurArchivage == 0
                          if projet.factures.length != 0
                              projet.factures.each do |facture|
                                  begin
                                      facture.destroy
                                  rescue => e  # Incident destroy Facture
                                      @erreur = Erreur.new
                                      @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                                      @erreur.appli = 'rails - ParamunsController - destroy'
                                      @erreur.origine = "erreur destroy Facture - facture.id =" + facture.id.to_s
                                      @erreur.numLigne = '315'
                                      @erreur.message = e.message
                                      @erreur.parametreId = params[:id].to_s
                                      @erreur.save
                                      @erreurArchivage = 1
                                  end
                              end
                          end
                      end
                      # Suppression du Projet ---
                      if @erreurArchivage == 0
                          begin
                              projet.destroy
                          rescue => e  # Incident destroy Projet
                              @erreur = Erreur.new
                              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                              @erreur.appli = 'rails - ParamunsController - destroy'
                              @erreur.origine = "erreur destroy Projet - projet.id =" + projet.id.to_s
                              @erreur.numLigne = '333'
                              @erreur.message = e.message
                              @erreur.parametreId = params[:id].to_s
                              @erreur.save
                          end
                      end
                  end # --- Fin de l'examen d'une occurrence de Projet ---
              end ### FIN de l'examen de toutes les occurrences de Projet ----------------------------
              # Si Archivage des Projets -------------
              if @nbreProjetArchiver > 0
                  nbreDevisInactif = 0
                  nbreProjetInactif = 0
                  nbreProjetClos = 0
                  @paramunold.projetolds.each do |projetold|
                      case projetold.proSituation.to_s
                          when '20'
                              nbreDevisInactif += 1
                          when '21'
                              nbreProjetInactif += 1
                          when '22'
                              nbreProjetClos += 1
                      end
                  end
                  @paramun.nbreDevisInactif = nbreDevisInactif.to_s
                  @paramun.nbreProjetInactif = nbreProjetInactif.to_s
                  @paramun.nbreProjetClos = nbreProjetClos.to_s
                  @majParamun = 1
              end 
          end ## FIN du Traitement des Projets ACTIFS ------

          ## TRAITEMENT DES PROJETS INACTIFS en Dépassement du Seuil de la Franchise *****
          if @depassOK == 1
              if @paramunold.projetolds.length > 0
                  projet_inactif_depass_seuil_trait
              end
          end

          ## Dépassement du Seuil de la Franchise : Maj @paramun.parDepass
          if @depassOK == 1
              totalProjet = @cptProjet + @cptProjetold
              if totalProjet == 0
                  @parDepassArray[1] = '0'
              else
                  @parDepassArray[1] = totalProjet
              end
              @paramun.parDepass = @parDepassArray.join(",")
              @paramun.save
          end

          ## Constitution des Statistiques de Suivi (pour l'Ecran d'Accueil) ############
          @statRecetteAccueilArray = []
          @statDepenseAccueilArray = []
          @statFactureAccueilArray = []
          @sixDernierMoisArray = []
          # Initialisation des Array
          stat_suivi_init_trait         
          ## Collecte des données pour implémentation dans les Array respectives -------------------
          ## Examen des Recettes -------
          if @paramun.recettes.length != 0
              @paramun.recettes.each do |recette|
                  if recette.montantHt.to_i >= 0
                      @aaaammRecette = recette.facDateReception.slice(6,4) + recette.facDateReception.slice(3,2)
                  else
                      # Détermination (éventuelle) de @aaaammRecette à partir de recette.facDateEmis
                      get_ecriture_initiale_positive_trait(recette)
                  end
                  ind = @statRecetteAccueilArray.find_index(@aaaammRecette)
                  if ind != nil
                      ind +=1
                      montant1 = @statRecetteAccueilArray[ind].to_i
                      montant2 = recette.montantHt.to_i / 100
                      @statRecetteAccueilArray[ind] = montant1 + montant2.to_i
                  end
              end
          end
          ## Examen des Dépenses -------
          if @paramun.depenses.length != 0
              @paramun.depenses.each do |depense|
                  aaaamm = depense.dateRegl.slice(6,4) + depense.dateRegl.slice(3,2)
                  ind = @statDepenseAccueilArray.find_index(aaaamm)
                  if ind != nil
                      ind +=1
                      montant1 = @statDepenseAccueilArray[ind].to_i
                      montant2 = depense.montantHt.to_i / 100
                      @statDepenseAccueilArray[ind] = montant1 + montant2.to_i 
                  end
              end
          end
          ## Examen des Factures impayées -------
          if @paramun.projets.length != 0
              stat_suivi_factureimpayee_trait
          end
          ## Enregistrement -----
          @paramun.statRecetteAccueil = @statRecetteAccueilArray.join('|')
          @paramun.statDepenseAccueil = @statDepenseAccueilArray.join('|')
          @paramun.statFactureAccueil = @statFactureAccueilArray.join('|')
          @paramun.save
          ## FIN Constitution des Statistiques de Suivi ###########################

          ## Fermeture de l'Application -----------------------------------
          head :no_content

      else ## Suppression d'une occurrence de Paramun #####################################
          ## en chantier *****************
          @paramun.destroy
          redirect_to parametres_url, notice: 'Parametre was successfully destroyed.'
      end
  end

  private
    # Only allow a trusted parameter "white list" through.
    def paramun_params
      params.require(:parametre).permit!
    end

end
