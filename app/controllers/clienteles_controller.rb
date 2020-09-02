class ClientelesController < ApplicationController

  # TEST de Connexion *******************
  before_action :authenticate_rights
  def authenticate_rights
      dateConnex = params[:parametre][:parDateConnex]
      @paramun = Paramun.find(params[:parametre][:id].to_i)

      if dateConnex.to_i > @paramun.parDateConnex.to_i
          respond_to do |format|
              format.xml { render request.format.to_sym => "ccliErreurS" }
          end
      end
  end


  # GET /clienteles ****** CHARGEMENT ************************
  # GET /clienteles.xml
  def index
      @clienteles = @paramun.clienteles

      respond_to do |format|
          if @clienteles.empty?
               format.xml { render request.format.to_sym => "ccliErreurA" } ## Aucune Clientele
          else  
               format.xml { render xml: @clienteles }
          end
      end
  end


  # POST /clienteles ********* CREATE ***************************************************
  # POST /clienteles.xml
  def create
      @current_time = DateTime.now
      @erreurCreate = 0
      @clientele = Clientele.new(clientele_params)
      begin
          @clientele.save
      rescue => e # Incident lors de la création de Clientele
          @erreur = Erreur.new
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = "1"
          @erreur.origine = "ClientelesController[create]: erreur Création Clientele"
          @erreur.numLigne = '39'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:id].to_s
          @erreur.save
          @erreurCreate = 1
      end
      respond_to do |format|
          if @erreurCreate == 0
              format.xml { render xml: @clientele }
          else
              format.xml { render request.format.to_sym => "ccliErreurC" }
          end
      end
  end


  # PUT /clienteles/1 ********* MISE A JOUR ***********************************************
  # PUT /clienteles/1.xml
  def update
      @current_time = DateTime.now
      @erreurUpdate = 0
      begin
          @clientele = Clientele.find(params[:id])
          begin
              @clientele.update(clientele_params)
          rescue => e # Incident Save Clientele
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = "1"
              @erreur.origine = "ClientelesController[update]: clientele.id=" + params[:id].to_s
              @erreur.numLigne = '69'
              @erreur.message = e.message
              @erreur.parametreId = params[:parametre][:id].to_s
              @erreur.save
              @erreurUpdate = 1
          end
      rescue => e # Incident Find de Clientele
          @erreur = Erreur.new
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = "1"
          @erreur.origine = "ClientelesController[update]: Clientele.find(params[:id])" + params[:id].to_s
          @erreur.numLigne = '67'
          @erreur.message = e.message
          @erreur.parametreId = ""
          @erreur.save
          @erreurUpdate = 1
      end
      respond_to do |format|
          if @erreurUpdate == 0
              format.xml { render request.format.to_sym => "cclienteleOK" }
          else
              format.xml { render request.format.to_sym => "ccliErreurU" }
          end
      end
  end


  # DELETE /clienteles/1 ********* SUPPRESSION *******************************************
  # DELETE /clienteles/1.xml
  def destroy
      @current_time = DateTime.now
      @erreurDestroy = 0
      begin
          @clientele = Clientele.find(params[:id])
          ## Suppression des (éventuels) Contacts -----------------
          if @clientele.contacts.length > 0
              @clientele.contacts.each do |contact|
                  begin
                      @contact.destroy
                  rescue => e # Incident destroy Contact
                      @erreur = Erreur.new
                      @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                      @erreur.appli = '1'
                      @erreur.origine = 'ClientelesController[destroy]: Suppression Contact - contact.id=' + contact.id.to_s +
                                        'Clientele.find(params[:id])=' + params[:id].to_s
                      @erreur.numLigne = '113'
                      @erreur.message = e.message
                      @erreur.parametreId = params[:parametre][:id].to_s
                      @erreur.save
                      @erreurDestroy = 1
                      break
                  end
              end
          end
      rescue => e # Incident Find Clientele
          @erreur = Erreur.new
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = '1'
          @erreur.origine = 'ClientelesController[destroy]:  Clientele.find(params[:id])=' + params[:id].to_s
          @erreur.numLigne = '108'
          @erreur.message = e.message
          @erreur.parametreId = ""
          @erreur.save
          @erreurDestroy = 1
      end
      # Suppression de Clientele ---------------
      if @erreurDestroy == 0
          begin
              @clientele.destroy
          rescue => e # Incident lors de la suppression de la Clientele
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = '1'
              @erreur.origine = "ClientelesController[destroy]: Delete Clientele - clientele.id=" + params[:id].to_s
              @erreur.numLigne = '143'
              @erreur.message = e.message
              @erreur.parametreId = params[:parametre][:id].to_s
              @erreur.save
              @erreurDestroy = 1
          end
      end
      respond_to do |format|
          if @erreurDestroy == 0
              format.xml { render request.format.to_sym => "cclienteleOK" }
          else
              format.xml { render request.format.to_sym => "ccliErreurD" }
          end
      end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def clientele_params
      params.require(:clientele).permit!
    end
end
