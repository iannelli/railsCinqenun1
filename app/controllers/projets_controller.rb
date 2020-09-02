class ProjetsController < ApplicationController

  # VERIFICATION de la Connexion *******************
  before_action :authenticate_rights
  def authenticate_rights
      dateConnex = params[:parametre][:parDateConnex]
      @paramun = Paramun.find(params[:parametre][:id].to_i)

      if dateConnex.to_i > @paramun.parDateConnex.to_i
          respond_to do |format|
              format.xml { render request.format.to_sym => "pproErreurS" }
          end
      end
  end


  # GET /projets ****** CHARGEMENT ************************
  # GET /projets
  def index
      @dateDuJour = Time.now
      @current_time = Time.now
      @indexOk = 0

      @projets = @paramun.projets
      if @projets.length == 0
          @indexOk = 0
      else
          @indexOk = 1
      end

      respond_to do |format|
          if @indexOk == 0
             format.xml { render request.format.to_sym => "pproErreurA" }  # Aucun Projet sélectionné
          else
             format.xml { render xml: @projets }
          end
      end
  end


  # POST /projets ********* CREATE ******************
  # POST /projets.xml
  def create
      @current_time = DateTime.now
      @erreurCreate = 0
      @projet = Projet.new(projet_params)
      begin
          @projet.parametreId = @paramun.id
          @projet.save
          if params[:projet][:clienteleFactureId].length != 0
              @clientele1 = Clientele.where(["id = ?", @projet.clienteleFactureId.to_i]).first
              unless @clientele1.nil?
                  if @clientele1.cliNature.to_s == 'Prospect'
                      @clientele1.cliNature = 'Client'
                      @clientele1.save
                  end
              end
          end
          unless params[:projet][:clienteleProjetId].nil?
              @clientele2 = Clientele.where(["id = ?", @projet.clienteleProjetId.to_i]).first
              unless @clientele2.nil?
                  if @clientele2.cliNature.to_s == 'Prospect'
                      @clientele2.cliNature = 'Client'
                      @clientele2.save
                  end
              end
          end
      rescue => e # Incident création du Projet
          @erreur = Erreur.new
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = '1'
          @erreur.origine = 'ProjetsController[create]: erreur Création Projet'
          @erreur.numLigne = '48/49'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:id].to_s
          @erreur.save
          @erreurCreate = 1
      end
      respond_to do |format|
          if @erreurCreate == 0
              format.xml { render xml: @projet }
          else
              format.xml { render request.format.to_sym => "pproErreurC" }
          end
      end
  end


  # PUT /projets/1 ********* MISE A JOUR ******************
  # PUT /projets/1.xml
  def update
      @current_time = DateTime.now
      @UpdateOK = 0
      @UpdateOProLib = 0      
      begin
          @projet = Projet.find(params[:id])
          if @projet.proLib.to_s != params[:projet][:proLib].to_s
              @UpdateOProLib = 1
          end
          begin
              @projet.update(projet_params)
              if @UpdateOProLib == 1
                  if @projet.taches.length != 0
                      @projet.taches.each do |tache|
                          tache.tacProLib = @projet.proLib.to_s
                          tache.save
                      end
                  end
              end
              ## Mal éventuelle de Clientele.cliNature
              if params[:projet][:clienteleFactureId].length != 0
                  @clientele1 = Clientele.where(["id = ?", @projet.clienteleFactureId]).first
                  unless @clientele1.nil?
                      if @clientele1.cliNature.to_s == 'Prospect'
                          @clientele1.cliNature = 'Client'
                          @clientele1.save
                      end
                  end
              end
              unless params[:projet][:clienteleProjetId].nil?
                  @clientele2 = Clientele.where(["id = ?", @projet.clienteleProjetId]).first
                  unless @clientele2.nil?
                      if @clientele2.cliNature.to_s == 'Prospect'
                          @clientele2.cliNature = 'Client'
                          @clientele2.save
                      end
                  end
              end
          rescue => e # Incident Maj Projet
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = '1'
              @erreur.origine = 'ProjetsController[update]: erreur update Projet - projet.id=' + @projet.id.to_s
              @erreur.numLigne = '101'
              @erreur.message = e.message
              @erreur.parametreId = params[:parametre][:id].to_s
              @erreur.save
              @UpdateOK = 1
          end
      rescue => e # Incident Find Projet
          @erreur = Erreur.new
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = 'rails'
          @erreur.origine = 'ProjetsController[update]:  Incident Find Projet=' + params[:id].to_s
          @erreur.numLigne = '96'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:id].to_s
          @erreur.save
          @UpdateOK = 1
      end
      respond_to do |format|
          if @UpdateOK == 0
              format.xml { render request.format.to_sym => "pprojetOK" }
          else
              format.xml { render request.format.to_sym => "pproErreurU" }
          end
      end
  end


  # DELETE /projets/1 ********* SUPPRESSION ******************
  # DELETE /projets/1.xml
  def destroy
      @current_time = DateTime.now
      @erreurDestroy = 0
      begin
          @projet = Projet.find(params[:id])
      rescue => e # Incident Find Projet 
            @erreur = Erreur.new
            @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
            @erreur.appli = '1'
            @erreur.origine = 'ProjetsController[destroy]: Incident Find Projet=' + params[:id].to_s
            @erreur.numLigne = '167'
            @erreur.message = e.message
            @erreur.parametreId = params[:parametre][:id].to_s
            @erreur.save
            @erreurDestroy = 1
      end
      ## Suppression des Taches (si existantes) -----------------
      if @erreurDestroy == 0
          if @projet.taches.length != 0
              @projet.taches.each do |tache|
                  begin
                      tache.destroy
                  rescue => e # erreur Tache destroy
                      @erreur = Erreur.new
                      @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                      @erreur.appli = '1'
                      @erreur.origine = 'ProjetsController[destroy]: Incident destroy Tache - tache.id=' + tache.id.to_s
                      @erreur.numLigne = '184'
                      @erreur.message = e.message
                      @erreur.parametreId = params[:parametre][:id].to_s
                      @erreur.save
                      @erreurDestroy = 1
                      break
                  end
              end
          end
      end
      ## Suppression du Bon de Commande (si pas d'autres factures existantes) -----------------
      if @erreurDestroy == 0
          if @projet.factures.length != 0
              @projet.factures.each do |facture|
                  begin
                      facture.destroy
                  rescue => e # Incident destroy Facture
                      @erreur = Erreur.new
                      @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                      @erreur.appli = '1'
                      @erreur.origine = 'ProjetsController[destroy]: Incident destroy Facture - facture.id=' + facture.id.to_s
                      @erreur.numLigne = '205'
                      @erreur.message = e.message
                      @erreur.parametreId = params[:parametre][:id].to_s
                      @erreur.save
                      @erreurDestroy = 1
                  end
              end
          end
      end
      if @erreurDestroy == 0
          begin
              @projet.destroy
          rescue => e # Incident destroy Projet
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = '1'
              @erreur.origine = "ProjetsController[destroy]: Incident destroy Projet - @projet.id=" + @projet.id.to_s
              @erreur.numLigne = '222'
              @erreur.message = e.message
              @erreur.parametreId = params[:parametre][:id].to_s
              @erreur.save
              @erreurDestroy = 1
          end
      end
      respond_to do |format|
          if @erreurDestroy == 0
              format.xml { render request.format.to_sym => "pprojetOK" }
          else
              format.xml { render request.format.to_sym => "pproErreurD" }
          end
      end
  end

   private
    # Never trust parameters from the scary internet, only allow the white list through.
    def projet_params
      params.require(:projet).permit!
    end
end
