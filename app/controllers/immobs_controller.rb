class ImmobsController < ApplicationController

  # TEST de Connexion *******************
  before_action :authenticate_rights
  def authenticate_rights
      dateConnex = params[:parametre][:parDateConnex]
      @paramun = Paramun.find(params[:parametre][:id].to_i)

      if dateConnex.to_i > @paramun.parDateConnex.to_i
          respond_to do |format|
              format.xml { render text: "iimmErreurS" }
          end
      end
  end


  # GET /immobs ****** CHARGEMENT ************************
  # GET /immobs.xml
  def index
      @immobs = @paramun.immobs

      respond_to do |format|
          if @immobs.empty?
               format.xml { render request.format.to_sym => "iimmErreurA" } ## Aucune Immobilisation
          else  
               format.xml { render xml: @immobs }
          end
      end
  end


  # POST /immobs ********* CREATE ******************
  # POST /immobs.xml
  def create
      @current_time = DateTime.now
      @current_year = DateTime.now.year
      @immob = Immob.new(immob_params)
      @CreateOK = 0
      begin
          @immob.save
      rescue => e # Incident création de Immob
          @erreur = Erreur.new
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = "rails - ImmobsController - create"
          @erreur.origine = "erreur Création Immob"
          @erreur.numLigne = '40'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:id].to_s
          @erreur.save
          @CreateOK = 1
      end
      if @CreateOK == 0
          ## Maj du Nombre de Immob --------------------------
          @nbreImmobArray = @paramun.nbreImmob.split(",")
          nbre = @nbreImmobArray[0].to_i + 1
          @arrayLog = []
          @nbreImmobArray[0] = nbre.to_s
          @paramun.nbreImmob = @nbreImmobArray.join(',')
          ## Maj parImmob --------------------------
          @imAmorArray = @immob.imAmorString.split("|")
          @parImmobArray = @paramun.parImmob.split(",")
          i = 0
          while i < @imAmorArray.length
              exerImmob = @imAmorArray[i+1].to_i
              indImAmor = immob_indice_millesime_trait(exerImmob)
              if indImAmor >= 1 && indImAmor <= 6
                  parImmob = @parImmobArray[indImAmor].to_i + @imAmorArray[i+2].to_i
                  @parImmobArray[indImAmor] = parImmob.to_s
              end
              i += 5
          end
          @paramun.parImmob = @parImmobArray.join(',')
          begin
              @paramun.save
          rescue => e # Incident save Parametre
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = "rails - ImmobsController - create"
              @erreur.origine = "erreur save Parametre"
              @erreur.numLigne = '74'
              @erreur.message = e.message
              @erreur.parametreId = params[:parametre][:id].to_s
              @erreur.save
              @CreateOK = 2
          end
      end
      respond_to do |format|
          case @CreateOK
              when 0
                  format.xml { render xml: @immob}
              when 1
                  format.xml { render request.format.to_sym => "iimmErreurC1" }
              when 2
                  format.xml { render request.format.to_sym => "iimmErreurC2" }
          end
      end
  end


  # PUT /immobs/1 ********* MODIFICATION ******************
  # PUT /immobs/1.xml
  def update
      @current_time = DateTime.now
      @current_year = DateTime.now.year
      @updateOK = 0
      begin
          @immob = Immob.find(params[:id])
      rescue => e # erreur Find Immob
          @erreur = Erreur.new
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = "rails - ImmobsController - update"
          @erreur.origine = "erreur Find Immob - immob.id=" + params[:id].to_s
          @erreur.numLigne = '112'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:id].to_s
          @erreur.save
          @updateOK = 1
      end
      if @updateOK == 0
          ## Maj de Immob ------
          begin
              @immob.update(immob_params)
          rescue => e # Incident lors de la Maj de Immob
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = "rails - ImmobsController - update"
              @erreur.origine = "erreur Modification Immob - immob.id=" + params[:id].to_s
              @erreur.numLigne = '187'
              @erreur.message = e.message
              @erreur.parametreId = params[:parametre][:id].to_s
              @erreur.save
              @updateOK = 2
          end
      end
      ## FIN du Traitement upDate ------
      respond_to do |format|
          case @updateOK
              when 0
                  format.xml { render request.format.to_sym => "iimmobOK0" }
              when 1
                  format.xml { render request.format.to_sym => "iimmErreurU1" }
              when 2
                  format.xml { render request.format.to_sym => "iimmErreurU2" }
          end
      end
  end


  # DELETE /immobs/1 ********* SUPPRESSION ******************
  # DELETE /immobs/1.xml
  def destroy
      @current_time = DateTime.now
      @current_year = DateTime.now.year
      @destroyOK = 0
      begin
          @immob = Immob.find(params[:id])
      rescue => e # Incident Find Depense
          @erreur = Erreur.new
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = 'rails - ImmobsController - destroy'
          @erreur.origine = "erreur Find Immob - Immob.find(params[:id])=" + params[:id].to_s
          @erreur.numLigne = '306'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:id].to_s
          @erreur.save
          @destroyOK = 1
      end
      if @destroyOK == 0 ## Mise à jour du Nombre de Immob
          @nbreImmobArray = @paramun.nbreImmob.split(",")
          nbre = @nbreImmobArray[0].to_i - 1
          @nbreImmobArray[0] = nbre.to_s
          @paramun.nbreImmob = @nbreImmobArray.join(',')
          begin
              @paramun.save
          rescue => e # Incident save Parametre
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = "rails - ImmobsController - destroy"
              @erreur.origine = "erreur save Parametre"
              @erreur.numLigne = '329'
              @erreur.message = e.message
              @erreur.parametreId = params[:parametre][:id].to_s
              @erreur.save
              @updateOK = 2
          end
      end
      if @destroyOK == 0
          begin
              @immob.destroy
          rescue => e # Incident lors de la suppression de Immob
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = 'rails - ImmobsController - destroy'
              @erreur.origine = "erreur Delete Immob - immob.id=" + params[:id].to_s
              @erreur.numLigne = '344'
              @erreur.message = e.message
              @erreur.parametreId = params[:parametre][:id].to_s
              @erreur.save
              @destroyOK = 3
          end
      end
      ## FIN du traitement
      respond_to do |format|
          case @destroyOK
              when 0
                  format.xml { render request.format.to_sym => "iimmobOK" }
              when 1
                  format.xml { render request.format.to_sym => "iimmErreurD1" }
              when 2
                  format.xml { render request.format.to_sym => "iimmErreurD2" }
              when 3
                  format.xml { render request.format.to_sym => "iimmErreurD3" }
          end
      end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def immob_params
      params.require(:immob).permit!
    end
end
