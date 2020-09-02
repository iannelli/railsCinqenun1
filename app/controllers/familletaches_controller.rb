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
    @CreateOK = 0
    @erreurCreate = ["0","0"]
    if @paramun.familletaches.length != 0
        @paramun.familletaches.each do |familletache|
            if familletache.famtacNum.to_s == params[:familletache][:famtacNum].to_s
                @erreurCreate[1] = "1" # 'famtacNum' déjà existant
            end
            if familletache.famtacLib.to_s == params[:familletache][:famtacLib].to_s
                @erreurCreate[0] = "1" # 'famtacLib' déjà existant
            end       
        end
        if @erreurCreate[1].to_s == "1" || @erreurCreate[0].to_s == "1"
            @CreateOK = 1
            @famErreurC = "ffamErreurC" + @erreurCreate.join.to_s
        end
    end
    if @CreateOK == 0
        @familletache = Familletache.new(familletache_params)
        @familletache.parametreId = params[:parametre][:id].to_i
        begin
            @familletache.save
        rescue => e # Incident création Familletache
            @erreur = Erreur.new
            @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
            @erreur.appli = "1"
            @erreur.origine = "FamilletachesController[create]: erreur Création Familletache"
            @erreur.numLigne = '56'
            @erreur.message = e.message
            @erreur.parametreId = params[:parametre][:id].to_s
            @erreur.save
            @CreateOK = 2
        end
    end
    respond_to do |format|
        case @CreateOK
            when 0
                format.xml { render xml: @familletache }
            when 1               
                format.xml { render request.format.to_sym => @famErreurC }
            when 2
                format.xml { render request.format.to_sym => "ffamErreurC2" }
        end
    end
  end


  # PUT /familletaches/1 ********* MISE A JOUR ******************
  # PUT /familletaches/1.xml
  def update
    @current_time = DateTime.now
    @UpdateOK = 0
    @erreurUpdate = ["0","0"]
    begin
        @familletache = Familletache.find(params[:id])
        @paramun.familletaches.each do |familletache|
            if familletache.id.to_i != params[:id].to_i
                if familletache.famtacNum.to_s == params[:familletache][:famtacNum].to_s
                    @erreurUpdate[1] = "1" # 'famtacNum' déjà existant
                end
                if familletache.famtacLib.to_s == params[:familletache][:famtacLib].to_s
                    @erreurUpdate[0] = "1" # 'famtacLib' déjà existant
                end
            end
        end
        if @erreurUpdate[1].to_s == "1" || @erreurUpdate[0].to_s == "1"
            @UpdateOK = 1
            @famErreurU = "ffamErreurU" + @erreurUpdate.join.to_s
        end

        if @UpdateOK == 0
            begin
                @familletache.update(familletache_params)
            rescue => e # Incident Save Familletache
                @erreur = Erreur.new
                @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                @erreur.appli = "1"
                @erreur.origine = "FamilletachesController[update]: erreur Familletache - Familletache.id=" + params[:id].to_s
                @erreur.numLigne = '107'
                @erreur.message = e.message
                @erreur.parametreId = params[:parametre][:id].to_s
                @erreur.save
                @UpdateOK = 2
            end
        end
    rescue => e # Incident Find de Familletache
        @erreur = Erreur.new
        @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
        @erreur.appli = "1"
        @erreur.origine = "FamilletachesController[update]: erreur Find Familletache.find(params[:id])=" + params[:id].to_s
        @erreur.numLigne = '89'
        @erreur.message = e.message
        @erreur.parametreId = params[:parametre][:id].to_s
        @erreur.save
        @UpdateOK = 2
    end
    respond_to do |format|
        case @UpdateOK
            when 0
                format.xml { render request.format.to_sym => "ffamilleOK" }
            when 1
                format.xml { render request.format.to_sym => @famErreurU }
            when 2
                format.xml { render request.format.to_sym => "ffamErreurU2" }
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
            @erreur.appli = '1'
            @erreur.origine = "FamilletachesController[destroy]: erreur Delete Familletache - familletache.id=" + params[:id].to_s
            @erreur.numLigne = '152'
            @erreur.message = e.message
            @erreur.parametreId = params[:parametre][:id].to_s
            @erreur.save
            @erreurDestroy = 1
        end
    rescue => e # Incident Find de Familletache
        @erreur = Erreur.new
        @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
        @erreur.appli = '1'
        @erreur.origine = "FamilletachesController[destroy]: erreur Find Familletache - familletache.id=" + params[:id].to_s
        @erreur.numLigne = '150'
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
