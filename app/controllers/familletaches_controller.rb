class FamilletachesController < ApplicationController

  # TEST de Connexion *******************
  before_action :authenticate_rights
  def authenticate_rights
      dateConnex = params[:parametre][:parDateConnex]
      @paramun = Paramun.find(params[:parametre][:id].to_i)

      if dateConnex.to_i > @paramun.parDateConnex.to_i
          respond_to do |format|
              format.xml { render request.format.to_sym => "ffamErreurS" }
          end
      end
  end


  # GET /familletaches ****** CHARGEMENT ************************
  # GET /familletaches.xml
  def index
      @familletaches = @paramun.familletaches

      respond_to do |format|
          if @familletaches.empty?
               format.xml { render request.format.to_sym => "ffamErreurA" } ## Aucune Familletache collectée
          else
               format.xml { render xml: @familletaches }
          end
      end
  end


  # POST /familletaches ********* CREATE ******************
  # POST /familletaches.xml
  def create
    @current_time = DateTime.now
    @erreurCreate = 0
    @familletache = Familletache.new(familletache_params)
    @familletache.parametreId = params[:parametre][:id].to_i
    begin
        @familletache.save
    rescue => e # Incident création Familletache
        @erreur = Erreur.new
        @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
        @erreur.appli = "rails - FamilletachesController - create"
        @erreur.origine = "erreur Création Familletache"
        @erreur.numLigne = '40'
        @erreur.message = e.message
        @erreur.parametreId = params[:parametre][:id].to_s
        @erreur.save
        @erreurCreate = 1
    end
    respond_to do |format|
        if @erreurCreate == 0
            format.xml { render xml: @familletache }
        else
            format.xml { render request.format.to_sym => "ffamErreurC" }
        end
    end
  end


  # PUT /familletaches/1 ********* MISE A JOUR ******************
  # PUT /familletaches/1.xml
  def update
    @current_time = DateTime.now
    @erreurUpdate = 0
    begin
        @familletache = Familletache.find(params[:id])
        begin
            @familletache.update(familletache_params)
        rescue => e # Incident Save Familletache
            @erreur = Erreur.new
            @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
            @erreur.appli = "rails - FamilletachesController - update"
            @erreur.origine = "erreur Save Familletache - Familletache.id=" + params[:id].to_s
            @erreur.numLigne = '70'
            @erreur.message = e.message
            @erreur.parametreId = params[:parametre][:id].to_s
            @erreur.save
            @erreurUpdate = 1
        end
    rescue => e # Incident Find de Familletache
        @erreur = Erreur.new
        @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
        @erreur.appli = "rails - FamilletachesController - update"
        @erreur.origine = "erreur Find Familletache.find(params[:id])=" + params[:id].to_s
        @erreur.numLigne = '68'
        @erreur.message = e.message
        @erreur.parametreId = params[:parametre][:id].to_s
        @erreur.save
        @erreurUpdate = 1
    end
    respond_to do |format|
        if @erreurUpdate == 0
          format.xml { render request.format.to_sym => "ffamilleOK" }
        else
          format.xml { render request.format.to_sym => "ffamErreurU" }
        end
    end
  end


  # DELETE /familletaches/1 ********* SUPPRESSION ******************
  # DELETE /familletaches/1.xml
  def destroy
    @current_time = DateTime.now
    @erreurDestroy = 0
    begin
        @familletache = Familletache.find(params[:id])
        begin
            @familletache.destroy
        rescue => e # Incident lors de la suppression de Familletache
            @erreur = Erreur.new
            @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
            @erreur.appli = 'rails - FamilletachesController - destroy'
            @erreur.origine = "erreur Delete Familletache - familletache.id=" + params[:id].to_s
            @erreur.numLigne = '111'
            @erreur.message = e.message
            @erreur.parametreId = params[:parametre][:id].to_s
            @erreur.save
            @erreurDestroy = 1
        end
    rescue => e # Incident Find de Familletache
        @erreur = Erreur.new
        @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
        @erreur.appli = 'rails - FamilletachesController - destroy'
        @erreur.origine = "erreur Find Familletache - familletache.id=" + params[:id].to_s
        @erreur.numLigne = '109'
        @erreur.message = e.message
        @erreur.parametreId = params[:parametre][:id].to_s
        @erreur.save
        @erreurDestroy = 1
    end 
    respond_to do |format|
        if @erreurDestroy == 0
            format.xml { render request.format.to_sym => "ffamilleOK" }
        else
            format.xml { render request.format.to_sym => "ffamErreurD" }
        end
    end
  end


  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def familletache_params
      params.require(:familletache).permit!
    end
end
