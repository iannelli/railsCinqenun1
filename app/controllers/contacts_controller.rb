class ContactsController < ApplicationController

  # TEST de Connexion *******************
  before_action :authenticate_rights
  def authenticate_rights
      dateConnex = params[:parametre][:parDateConnex]
      @paramun = Paramun.find(params[:parametre][:id].to_i)

      if dateConnex.to_i > @paramun.parDateConnex.to_i
          respond_to do |format|
              format.xml { render request.format.to_sym => "cconErreurS" }
          end
      end
  end


  # GET /contacts ****** CHARGEMENT ************************
  # GET /contacts.xml
  def index
      @clientele = Clientele.find(params[:clientele][:id])
      @contacts = @clientele.contacts

      respond_to do |format|
          if @contacts.empty?
              format.xml { render request.format.to_sym => "cconErreurA" }  # Aucun Contact collecté
          else
              format.xml { render xml: @contacts }
          end
      end
  end



  # POST /contacts ********* CREATE ***************************************
  # POST /contacts.xml
  def create
      @current_time = DateTime.now
      @erreurCreate = 0
      begin
          @clientele = Clientele.find(params[:clientele][:id])
          @contact = Contact.new(contact_params)
          @contact.clienteleId = @clientele.id.to_s
          begin
              @contact.save
          rescue => e
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = 'rails - ContactsController - create'
              @erreur.origine = 'Erreur Create Contact'
              @erreur.numLigne = '43'
              @erreur.message = e.message
              @erreur.parametreId = params[:parametre][:id].to_s
              @erreur.save
              @erreurCreate = 1
          end
      rescue => e  # erreur Find Clientele
          @erreur = Erreur.new
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = 'rails'
          @erreur.origine = 'ContactsController - create'
          @erreur.numLigne = '39'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:id].to_s
          @erreur.save
          @erreurCreate = 1
      end

      respond_to do |format|
        if @erreurCreate == 0
          format.xml { render xml: @contact }
        else
          format.xml { render request.format.to_sym => "cconErreurC" }
        end
      end
  end


  # PUT /contacts/1 ********* MISE A JOUR ****************************************
  # PUT /contacts/1.xml
  def update
      @current_time = DateTime.now
      @erreurUpdate = 0
      begin
          @contact = Contact.find(params[:id])
          begin
              @contact.update(contact_params)
          rescue => e # Incident Save Contact
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = "rails - ContactsController - update"
              @erreur.origine = "erreur Update Contact - Contact.id=" + params[:id].to_s
              @erreur.numLigne = '85'
              @erreur.message = e.message
              @erreur.parametreId = params[:parametre][:id].to_s
              @erreur.save
              @erreurUpdate = 1
          end
      rescue => e # Incident Find de Contact
          @erreur = Erreur.new
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = "rails - ContactsController - update"
          @erreur.origine = "erreur Find Contact.find(params[:id])=" + params[:id].to_s
          @erreur.numLigne = '83'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:id].to_s
          @erreur.save
          @erreurUpdate = 1
      end
      respond_to do |format|
          if @erreurUpdate == 0
            format.xml { render request.format.to_sym => "ccontactOK" }
          else
            format.xml { render request.format.to_sym => "cconErreurU" }
          end
      end
  end


  # DELETE /contacts/1 ********* SUPPRESSION ************************************************
  # DELETE /contacts/1.xml
  def destroy
      @current_time = DateTime.now
      @erreurDestroy = 0
      begin
          @contact = Contact.find(params[:id])
          begin
              @contact.destroy  # Suppression Contact ----------------------
          rescue => e  # erreur destroy de Contact
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = 'rails - ContactsController - destroy'
              @erreur.origine = "erreur destroy de Contact - @contact.id =" + @contact.id.to_s
              @erreur.numLigne = '126'
              @erreur.message = e.message
              @erreur.parametreId = params[:parametre][:id].to_s
              @erreur.save
              @erreurDestroy = 1
          end
       rescue => e # Incident Find Contact
            @erreur = Erreur.new
            @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
            @erreur.appli = 'rails - ContactsController - destroy'
            @erreur.origine = 'Incident Find - Contact.find(params[:id])=' + params[:id].to_s
            @erreur.numLigne = '124'
            @erreur.message = e.message
            @erreur.parametreId = params[:parametre][:id].to_s
            @erreur.save
            @erreurDestroy = 1
      end

      respond_to do |format|
          if @erreurDestroy == 0
              format.xml { render request.format.to_sym => "ccontactOK" }
          else
              format.xml { render request.format.to_sym => "cconErreurD" }
          end
      end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def contact_params
      params.require(:contact).permit!
    end
end
