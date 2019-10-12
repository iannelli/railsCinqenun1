class TypetachesController < ApplicationController

  # TEST de Connexion *******************
  before_action :authenticate_rights
  def authenticate_rights
      dateConnex = params[:parametre][:parDateConnex]
      @paramun = Paramun.find(params[:parametre][:id].to_i)

      if dateConnex.to_i > @paramun.parDateConnex.to_i
          respond_to do |format|
              format.xml { render text: "ttypErreurS0" }
          end
      end
  end


  # GET /typetaches ****** CHARGEMENT ************************
  # GET /typetaches.xml
  def index
      @typetaches = @paramun.typetaches

      respond_to do |format|
          if @typetaches.empty?
               format.xml { render request.format.to_sym => "ttypErreurA0" } ## Aucun Typetache collecté
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
              format.xml { render request.format.to_sym => "ttypErreurC0" }
          end
      end
  end


   # PUT /typetaches/1 ********* MISE A JOUR ******************
  # PUT /typetaches/1.xml
  def update
      @UpdateOK = 0
      begin
          @typetache = Typetache.find(params[:id])
          if @typetache.taches.length != 0
              @tacheArray = []
              @tacheString = ""
              @typetache.taches.each do |tache|
                  if ( (params[:typetache][:typetacUnite].length != 0 && tache.typetacUnite.to_s != params[:typetache][:typetacUnite].to_s) ||
                       (params[:typetache][:typetacET].length != 0 && tache.typetacET.to_s != params[:typetache][:typetacET].to_s) )
                      @tacheArray << tache.tacLibCourt.to_s
                      @tacheArray << tache.tacProLib.to_s
                  end
              end
              if @tacheArray.length != 0
                  @UpdateOK = 2
                  @tacheString = "ttypErreurU1" + @tacheArray.join('|')
              end
          end
          if @UpdateOK == 0
              @typetache.update(typetache_params)
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
          @UpdateOK = 1
      end
      respond_to do |format|
           case @UpdateOK
              when 0
                  format.xml { render request.format.to_sym => "ttypetacheOK" }
              when 1
                  format.xml { render request.format.to_sym => "ttypErreurU0" } # Erreur Find Typetache
              when 2
                  format.xml { render request.format.to_sym => @tacheString }  # Présence de Tache de 'typetacUnite' différent
          end
      end
  end


  # DELETE /typetaches/1 ********* SUPPRESSION ******************
  # DELETE /typetaches/1.xml
  def destroy
      @destroyOK = 0
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
          @destroyOK = 1
      end
      if @typetache.taches.length != 0
          @tacheArray = []
          @tacheString = ""
          @typetache.taches.each do |tache|
              @tacheArray << tache.tacLibCourt.to_s
              @tacheArray << tache.tacProLib.to_s
          end
          if @tacheArray.length != 0
              @destroyOK = 3
              @tacheString = "ttypErreurNO" + @tacheArray.join('|')
          end
      end
      if @destroyOK == 0
          begin
              @typetache.destroy
          rescue => e # Incident destroy Typetache
              @erreur = Erreur.new
              current_time = DateTime.now
              @erreur.dateHeure = current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = 'rails - TypetachesController - destroy'
              @erreur.origine = "erreur Delete Typetache - typetache.id=" + params[:id].to_s
              @erreur.numLigne = '134'
              @erreur.message = e.message
              @erreur.parametreId = params[:parametre][:id].to_s
              @erreur.save
              @destroyOK = 2
          end
      end
      respond_to do |format|
          case @destroyOK
              when 0
                  format.xml { render request.format.to_sym => "ttypetacheOK" }
              when 1
                  format.xml { render request.format.to_sym => "ttypErreurD1" } # Incident Find
              when 2
                  format.xml { render request.format.to_sym => "ttypErreurD2" } # Incident Destroy
              when 3                     
                  format.xml { render request.format.to_sym => @tacheString }  # Présence de Tache pour ce Type de tache
          end
      end
  end


  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def typetache_params
      params.require(:typetache).permit!
    end
end
