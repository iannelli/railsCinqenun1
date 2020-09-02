class TachesController < ApplicationController

  # TEST de Connexion *******************
  before_action :authenticate_rights
  def authenticate_rights
      dateConnex = params[:parametre][:parDateConnex]
      @paramun = Paramun.find(params[:parametre][:id].to_i)

      if dateConnex.to_i > @paramun.parDateConnex.to_i
          respond_to do |format|
              format.xml { render request.format.to_sym => "ttacErreurS" }
          end
      end
  end



  # GET /taches ****** CHARGEMENT ************************
  # GET /taches.xml
  def index
      @projet = Projet.find(params[:projet][:id])
      @taches = @projet.taches

      respond_to do |format|
          if @taches.empty?
              format.xml { render request.format.to_sym => "ttacErreurA" }  # Aucune Tache collectée
          else
              format.xml { render xml: @taches }
          end
      end
  end


  # POST /taches ********* CREATE ******************
  # POST /taches.xml
  def create
      @current_time = DateTime.now
      @erreurCreate = 0
      @tache = Tache.new(tache_params)
      begin
          @projet = Projet.find(params[:projet][:id])
          @tache.projetId = @projet.id.to_i
          begin
              @projet.update(projet_params)
          rescue => e # Incident Update Projet
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = '1'
              @erreur.origine = 'TachesController[create]: Incident Update Projet.id=' + params[:projet][:id].to_s
              @erreur.numLigne = '42'
              @erreur.message = e.message
              @erreur.parametreId = params[:parametre][:id].to_s
              @erreur.save
              @erreurCreate = 1
          end
      rescue => e  # erreur Find Projet
            @erreur = Erreur.new
            @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
            @erreur.appli = "1"
            @erreur.origine = "TachesController[create]: erreur Projet.find(params[:projet][:id])=" + params[:projet][:id].to_s
            @erreur.numLigne = '41'
            @erreur.message = e.message
            @erreur.parametreId = params[:parametre][:id].to_s
            @erreur.save
            @erreurCreate = 1
      end
      if @erreurCreate == 0
          begin
              @tache.save
          rescue => e # Incident création Tache
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = "1"
              @erreur.origine = "TachesController[create]: erreur Création Tache"
              @erreur.numLigne = '69'
              @erreur.message = e.message
              @erreur.parametreId = params[:parametre][:id].to_s
              @erreur.save
              @erreurCreate = 1
          end 
      end
      respond_to do |format|
          if @erreurCreate == 0
              format.xml { render xml: @tache }
          else
              format.xml { render request.format.to_sym => "ttacErreurC" }
          end
      end
  end



  # PUT /taches/1 ********* MISE A JOUR ******************
  # PUT /taches/1.xml
  def update
      @current_time = DateTime.now
      @erreurUpdate = 0
      begin
          @tache = Tache.find(params[:id])
      rescue => e  # erreur Find Tache
          @erreur = Erreur.new
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = "1"
          @erreur.origine = "TachesController[update]: erreur Tache.find(params[:id])=" + params[:id].to_s
          @erreur.numLigne = '99'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:id].to_s
          @erreur.save
          @erreurUpdate = 1
      end
      if @erreurUpdate == 0 # Maj Projet -------------------------
          begin
              @projet = Projet.find(params[:projet][:id])
              begin
                  @projet.update(projet_params)
              rescue => e # Incident Maj Projet
                  @erreur = Erreur.new
                  @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                  @erreur.appli = '1'
                  @erreur.origine = 'TachesController[update]: Incident Maj Projet.id=' + params[:projet][:id].to_s
                  @erreur.numLigne = '115'
                  @erreur.message = e.message
                  @erreur.parametreId = params[:parametre][:id].to_s
                  @erreur.save
                  @erreurUpdate = 1
              end
          rescue => e  # erreur Find Projet
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = "1"
              @erreur.origine = "TachesController[update]: Incident Projet.find(params[:projet][:id])=" + params[:projet][:id].to_s
              @erreur.numLigne = '113'
              @erreur.message = e.message
              @erreur.parametreId = params[:parametre][:id].to_s
              @erreur.save
              @erreurUpdate = 1
          end
      end
      if @erreurUpdate == 0 # Maj Tache -------------------------
          begin
              @tache.update(tache_params)
          rescue => e
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = '1'
              @erreur.origine = 'TachesController[update]: Maj Tache - tache.id=' + params[:id].to_s
              @erreur.numLigne = '141'
              @erreur.message = e.message
              @erreur.parametreId = params[:parametre][:id].to_s
              @erreur.save
              @erreurUpdate = 1
          end
      end
      respond_to do |format|
          if @erreurUpdate == 0
              format.xml { render request.format.to_sym => "ttacheOK" }
          else
              format.xml { render request.format.to_sym => "ttacErreurU" }
          end
      end
  end



  # DELETE /taches/1 ********* SUPPRESSION ******************
  # DELETE /taches/1.xml
  def destroy
      @current_time = DateTime.now
      @erreurDestroy = 0
      # Suppression Tache ----------------------
      begin
          @tache = Tache.find(params[:id])
          begin
              @tache.destroy
          rescue => e # Incident destroy Tache
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = '1'
              @erreur.origine = 'Incident destroy Tache.id=' + params[:id].to_s
              @erreur.numLigne = '174'
              @erreur.message = e.message
              @erreur.parametreId = params[:parametre][:id].to_s
              @erreur.save
              @erreurDestroy = 1
          end
      rescue => e # Incident Find Tache
          @erreur = Erreur.new
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = '1'
          @erreur.origine = 'TachesController[destroy]: Incident Find Tache.id=' + params[:id].to_s
          @erreur.numLigne = '172'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:id].to_s
          @erreur.save
          @erreurDestroy = 1
      end
      if @erreurDestroy == 0
          # Maj Projet ----------------------
          begin
              @projet = Projet.find(params[:projet][:id])
              begin
                  @projet.update(projet_params)
              rescue => e
                  @erreur = Erreur.new
                  @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                  @erreur.appli = '1'
                  @erreur.origine = 'TachesController[destroy]: Maj Projet - projet.id=' + params[:projet][:id].to_s
                  @erreur.numLigne = '202'
                  @erreur.message = e.message
                  @erreur.parametreId = params[:parametre][:id].to_s
                  @erreur.save
                  @erreurDestroy = 1
              end
          rescue => e # Incident Find Projet
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = '1'
              @erreur.origine = 'TachesController[destroy]: Incident Projet.find(params[:projet][:id])=' + params[:projet][:id].to_s
              @erreur.numLigne = '200'
              @erreur.message = e.message
              @erreur.parametreId = params[:parametre][:id].to_s
              @erreur.save
              @erreurDestroy = 1
          end
      end
      respond_to do |format|
          if @erreurDestroy == 0
              format.xml { render request.format.to_sym => "ttacheOK" }
          else
              format.xml { render request.format.to_sym => "ttacErreurD" }
          end
      end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def tache_params
      params.require(:tache).permit!
    end
    def projet_params
      params.require(:projet).permit!
    end
end
