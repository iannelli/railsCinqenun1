class SoustraitantsController < ApplicationController

  # TEST de Connexion *******************
  before_action :authenticate_rights
  def authenticate_rights
      dateConnex = params[:parametre][:parDateConnex]
      @paramun = Paramun.find(params[:parametre][:id].to_i)

      if dateConnex.to_i > @paramun.parDateConnex.to_i
          respond_to do |format|
              format.xml { render request.format.to_sym => "ssouErreurS" }
          end
      end
  end


  # GET /soustraitants ****** CHARGEMENT ************************
  # GET /soustraitants.xml
  def index
    @soustraitants = @paramun.soustraitants

    respond_to do |format|
        if @soustraitants.empty?
             format.xml { render request.format.to_sym => "ssouErreurA" } ## Aucun Soustraitant collecté
        else
             format.xml { render xml: @soustraitants }
        end
    end
  end


  # POST /soustraitants ********* CREATE ******************
  # POST /soustraitants.xml
  def create
    @current_time = DateTime.now
    @erreurCreate = 0
    @soustraitant = Soustraitant.new(soustraitant_params)
    @soustraitant.parametreId = params[:parametre][:id].to_i
    begin
        @soustraitant.save
    rescue => e # Incident création Soustraitant
        @erreur = Erreur.new
        @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
        @erreur.appli = "rails - SoustraitantsController - create"
        @erreur.origine = "erreur Création Soustraitant"
        @erreur.numLigne = '40'
        @erreur.message = e.message
        @erreur.parametreId = params[:parametre][:id].to_s
        @erreur.save
        @erreurCreate = 1
    end
    respond_to do |format|
        if @erreurCreate == 0
            format.xml { render xml: @soustraitant }
        else
            format.xml { render request.format.to_sym => "ssouErreurC" }
        end
    end
  end


  # PUT /soustraitants/1 ********* MISE A JOUR ******************
  # PUT /soustraitants/1.xml
  def update
    @current_time = DateTime.now
    @erreurUpdate = 0
    begin
        @soustraitant = Soustraitant.find(params[:id])
        begin
            @soustraitant.update(soustraitant_params)
        rescue => e # Incident Save Soustraitant
            @erreur = Erreur.new
            @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
            @erreur.appli = "rails - SoustraitantsController - update"
            @erreur.origine = "Incident Update Soustraitant.id=" + params[:id].to_s
            @erreur.numLigne = '70'
            @erreur.message = e.message
            @erreur.parametreId = params[:parametre][:id].to_s
            @erreur.save
            @erreurUpdate = 1
        end
    rescue => e # Incident Find Soustraitant
        @erreur = Erreur.new
        @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
        @erreur.appli = "rails - SoustraitantsController - update"
        @erreur.origine = "Incident Find Soustraitant.find(params[:id])=" + params[:id].to_s
        @erreur.numLigne = '68'
        @erreur.message = e.message
        @erreur.parametreId = params[:parametre][:id].to_s
        @erreur.save
        @erreurUpdate = 1
    end
    respond_to do |format|
        if @erreurUpdate == 0
            format.xml { render request.format.to_sym => "ssoustraitOK" }
        else
            format.xml { render request.format.to_sym => "ssouErreurU" }
        end
    end
  end


  # DELETE /soustraitants/1 ********* SUPPRESSION ******************
  # DELETE /soustraitants/1.xml
  def destroy
    @current_time = DateTime.now
    @erreurDestroy = 0
    begin
        @soustraitant = Soustraitant.find(params[:id])
        begin
            @soustraitant.destroy
        rescue => e # Incident lors de la suppression de Soustraitant
            @erreur = Erreur.new
            @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
            @erreur.appli = 'rails - SoustraitantsController - destroy'
            @erreur.origine = "erreur Delete Soustraitant.id=" + params[:id].to_s
            @erreur.numLigne = '111'
            @erreur.message = e.message
            @erreur.parametreId = params[:parametre][:id].to_s
            @erreur.save
            @erreurDestroy = 1
        end
    rescue => e # Incident Find de Soustraitant
        @erreur = Erreur.new
        @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
        @erreur.appli = 'rails - SoustraitantsController - destroy'
        @erreur.origine = "erreur Find Soustraitant.id=" + params[:id].to_s
        @erreur.numLigne = '109'
        @erreur.message = e.message
        @erreur.parametreId = params[:parametre][:id].to_s
        @erreur.save
        @erreurDestroy = 1
    end
    respond_to do |format|
        if @erreurDestroy == 0
            format.xml { render request.format.to_sym => "ssoustraitOK" }
        else
            format.xml { render request.format.to_sym => "ssouErreurD" }
        end
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def soustraitant_params
      params.require(:soustraitant).permit!
    end
end
