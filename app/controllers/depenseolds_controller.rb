class DepenseoldsController < ApplicationController

  # GET /depenseolds ****** CHARGEMENT ************************
  # GET /depenseolds
  def index
      #@depenseolds = Depenseold.all
      @IndexOK = 0
      # Find Parametreold ---
      begin
          @paramunold = Paramunold.find(params[:parametre][:id].to_i)
       rescue => e    
          @erreur = Erreur.new
          @current_time = DateTime.now
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = 'rails - DepenseoldsController - index'
          @erreur.origine = 'Incident Find Parametreold - params[:parametre][:id]=' + params[:parametre][:id].to_s
          @erreur.numLigne = '10'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:id].to_s
          @erreur.save
          @IndexOK = 1
      end
      if @IndexOK == 0
          @depenseolds = @paramunold.depenseolds
      end
      respond_to do |format|
          if @IndexOK == 1
              format.xml { render request.format.to_sym => "odeErreurI" }  # Incident Find Parametreold
          else
              if @depenseolds.empty?
                 format.xml { render request.format.to_sym => "odeErreurA" }  # Aucun Recetteold sélectionné
              else
                 format.xml { render xml: @depenseolds }
              end
          end
      end
  end

  # POST /depenseolds
  def create
    @depenseold = Depenseold.new(depenseold_params)

    if @depenseold.save
      redirect_to @depenseold, notice: 'Depenseold was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /depenseolds/1
  def update
    if @depenseold.update(depenseold_params)
      redirect_to @depenseold, notice: 'Depenseold was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /depenseolds/1
  def destroy
    @depenseold.destroy
    redirect_to depenseolds_url, notice: 'Depenseold was successfully destroyed.'
  end


  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def depenseold_params
        params[:depenseold]
    end
end
