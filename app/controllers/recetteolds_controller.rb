class RecetteoldsController < ApplicationController

  # GET /recetteolds ****** CHARGEMENT ************************
  # GET /recetteolds
  def index
      #@recetteolds = Recetteold.all
      @IndexOK = 0
      # Find Parametreold ---
      begin
          @paramunold = Paramunold.find(params[:parametre][:id].to_i)
       rescue => e
          @erreur = Erreur.new
          @current_time = DateTime.now
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = 'rails - RecetteoldsController - index'
          @erreur.origine = 'Incident Find Parametreold - @paramunold.id=' + params[:parametre][:id].to_s
          @erreur.numLigne = '10'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:id].to_s
          @erreur.save
          @IndexOK = 1
      end
      if @IndexOK == 0
          @recetteolds = @paramunold.recetteolds
      end
      respond_to do |format|
          if @IndexOK == 1
              format.xml { render request.format.to_sym =>  "oreErreurI" }  # Incident Find Parametreold
          else
              if @recetteolds.empty?
                 format.xml { render request.format.to_sym =>  "oreErreurA" }  # Aucun Recetteold sélectionné
              else
                 format.xml { render xml: @recetteolds }
              end
          end
      end
  end


  # POST /recetteolds
  def create
    @recetteold = Recetteold.new(recetteold_params)

    if @recetteold.save
      redirect_to @recetteold, notice: 'Recetteold was successfully created.'
    else
      render :new
    end
  end


  # PATCH/PUT /recetteolds/1
  def update
    if @recetteold.update(recetteold_params)
      redirect_to @recetteold, notice: 'Recetteold was successfully updated.'
    else
      render :edit
    end
  end


  # DELETE /recetteolds/1
  def destroy
    @recetteold.destroy
    redirect_to recetteolds_url, notice: 'Recetteold was successfully destroyed.'
  end

  private
    # Only allow a trusted parameter "white list" through.
    def recetteold_params
      params.require(:recetteold).permit!
    end
end
