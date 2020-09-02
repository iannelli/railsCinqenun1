class ImmoboldsController < ApplicationController


  # GET /immobolds ****** CHARGEMENT ************************
  # GET /immobolds.xml
  def index
      #@immobolds = Immobold.all
      @IndexOK = 0
      # Find Parametreold ---
      begin
          @paramunold = Paramunold.find(params[:parametre][:id].to_i)
       rescue => e
          @erreur = Erreur.new
          @current_time = DateTime.now
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = '1'
          @erreur.origine = 'ImmoboldsController[index]: Incident Find Parametreold - params[:parametre][:id]=' + params[:parametre][:id].to_s
          @erreur.numLigne = '11'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:id].to_s
          @erreur.save
          @IndexOK = 1
      end
      if @IndexOK == 0
          @immobolds = @paramunold.immobolds
      end
      respond_to do |format|
          if @IndexOK == 1
              format.xml { render request.format.to_sym => "oimErreurI" }  # Incident Find Parametreold
          else
              if @immobolds.empty?
                 format.xml { render request.format.to_sym => "oimErreurA" }  # Aucun Immobold sélectionné
              else
                 format.xml { render xml: @immobolds }
              end
          end
      end
  end


  # POST /immobolds
  # POST /immobolds.json
  def create
    @immobold = Immobold.new(immobold_params)

    respond_to do |format|
      if @immobold.save
        format.html { redirect_to @immobold, notice: 'Immobold was successfully created.' }
        format.json { render :show, status: :created, location: @immobold }
      else
        format.html { render :new }
        format.json { render json: @immobold.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /immobolds/1
  # PATCH/PUT /immobolds/1.json
  def update
    respond_to do |format|
      if @immobold.update(immobold_params)
        format.html { redirect_to @immobold, notice: 'Immobold was successfully updated.' }
        format.json { render :show, status: :ok, location: @immobold }
      else
        format.html { render :edit }
        format.json { render json: @immobold.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /immobolds/1
  # DELETE /immobolds/1.json
  def destroy
    @immobold.destroy
    respond_to do |format|
      format.html { redirect_to immobolds_url, notice: 'Immobold was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_immobold
      @immobold = Immobold.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def immobold_params
      params.fetch(:immobold, {})
    end
end
