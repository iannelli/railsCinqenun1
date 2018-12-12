class TypetachesController < ApplicationController

  # TEST de Connexion *******************
  before_action :authenticate_rights
  def authenticate_rights
      dateConnex = params[:parametre][:parDateConnex]
      @paramun = Paramun.find(params[:parametre][:id].to_i)

      if dateConnex.to_i > @paramun.parDateConnex.to_i
          respond_to do |format|
              format.xml { render text: "ttypErreurS" }
          end
      end
  end


  # GET /typetaches ****** CHARGEMENT ************************
  # GET /typetaches.xml
  def index
      @typetaches = @paramun.typetaches

      respond_to do |format|
          if @typetaches.empty?
               format.xml { render request.format.to_sym => "ttypErreurA" } ## Aucun Typetache collecté
          else  
               format.xml { render xml: @typetaches }
          end
      end
  end


  # POST /typetaches ********* CREATE ******************
  # POST /typetaches.xml
  def create
      @current_time = DateTime.now
      @erreurCreate = 0
      @typetache = Typetache.new(typetache_params)
      @typetache.parametreId = params[:parametre][:id].to_i
      begin
          @typetache.save
      rescue => e # Incident création Typetache
          @erreur = Erreur.new
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = "rails - TypetachesController - create"
          @erreur.origine = "erreur Création Typetache"
          @erreur.numLigne = '40'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:id].to_s
          @erreur.save
          @erreurCreate = 1
      end
      respond_to do |format|
          if @erreurCreate == 0
              format.xml { render xml: @typetache }
          else
              format.xml { render request.format.to_sym => "ttypErreurC" }
          end
      end
  end


   # PUT /typetaches/1 ********* MISE A JOUR ******************
  # PUT /typetaches/1.xml
  def update
      @erreurUpdate = 0
      begin
          @typetache = Typetache.find(params[:id])
          begin
              @typetache.update(typetache_params)
          rescue => e # Incident update Typetache
              @erreur = Erreur.new
              current_time = DateTime.now
              @erreur.dateHeure = current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = "rails - TypetachesController - update"
              @erreur.origine = "Incident update Typetache.id=" + params[:id].to_s
              @erreur.numLigne = '69'
              @erreur.message = e.message
              @erreur.parametreId = params[:parametre][:id].to_s
              @erreur.save
              @erreurUpdate = 1
          end
      rescue => e # Incident Find Typetache
          @erreur = Erreur.new
          current_time = DateTime.now
          @erreur.dateHeure = current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = "rails - TypetachesController - update"
          @erreur.origine = "Incident Find Typetache.id=" + params[:id].to_s
          @erreur.numLigne = '67'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:id].to_s
          @erreur.save
          @erreurUpdate = 1
      end
      respond_to do |format|
          if @erreurUpdate == 0
              format.xml { render request.format.to_sym => "ttypetacheOK" }
          else
              format.xml { render request.format.to_sym => "ttypErreurU" }
          end
      end
  end


  # DELETE /typetaches/1 ********* SUPPRESSION ******************
  # DELETE /typetaches/1.xml
  def destroy
      @erreurDestroy = 0
      begin
          @typetache = Typetache.find(params[:id])
      rescue => e  # Incident Find Typetache
          @erreur = Erreur.new
          current_time = DateTime.now
          @erreur.dateHeure = current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = 'rails - TypetachesController - destroy'
          @erreur.origine = "Incident Find Typetache.find(params[:id])=" + params[:id].to_s
          @erreur.numLigne = '109'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:id].to_s
          @erreur.save
          @erreurDestroy = 1
      end
      if @erreurDestroy == 0
          begin
              @typetache.destroy
          rescue => e # Incident destroy Typetache
              @erreur = Erreur.new
              current_time = DateTime.now
              @erreur.dateHeure = current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = 'rails - TypetachesController - destroy'
              @erreur.origine = "erreur Delete Typetache - typetache.id=" + params[:id].to_s
              @erreur.numLigne = '124'
              @erreur.message = e.message
              @erreur.parametreId = params[:parametre][:id].to_s
              @erreur.save
              @erreurDestroy = 1
          end
      end
      respond_to do |format|
          if @erreurDestroy == 0
              format.xml { render request.format.to_sym => "ttypetacheOK" }
          else
              format.xml { render request.format.to_sym => "ttypErreurD" }
          end
      end
  end


  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def typetache_params
      params.require(:typetache).permit!
    end
end
