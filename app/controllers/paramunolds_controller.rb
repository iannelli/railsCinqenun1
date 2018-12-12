class ParamunoldsController < ApplicationController

  # GET /paramunolds
  # GET /paramunolds.json
  def index
      #@paramunolds = Paramunold.all
      @erreurIndex = 0
      begin
          @paramunold = Paramunold.find(params[:parametre][:id].to_i)
      rescue => e  # Incident Find Tache
          @erreurold = Erreurold.new
          @erreurold.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreurold.appli = "rails - ParamunoldsController - index"
          @erreurold.origine = "erreur Find tache - @paramunold=" + params[:parametre][:id].to_s
          @erreurold.numLigne = '7'
          @erreurold.message = e.message
          @erreurold.parametreoldId = params[:parametre][:id].to_s
          @erreurold.save
          @erreurIndex = 1
      end
      respond_to do |format|
          if @erreurIndex == 1
             format.xml { render request.format.to_sym => "opaErreur" }  # Aucun Parametreold trouvé
          else
             format.xml { render xml: @paramunold }
          end
      end
  end



  # POST /paramunolds
  # POST /paramunolds.json
  def create
    @paramunold = Paramunold.new(paramunold_params)

    respond_to do |format|
      if @paramunold.save
        format.html { redirect_to @paramunold, notice: 'Paramunold was successfully created.' }
        format.json { render :show, status: :created, location: @paramunold }
      else
        format.html { render :new }
        format.json { render json: @paramunold.errors, status: :unprocessable_entity }
      end
    end
  end



  # PATCH/PUT /paramunolds/1
  # PATCH/PUT /paramunolds/1.json
  def update
    respond_to do |format|
      if @paramunold.update(paramunold_params)
        format.html { redirect_to @paramunold, notice: 'Paramunold was successfully updated.' }
        format.json { render :show, status: :ok, location: @paramunold }
      else
        format.html { render :edit }
        format.json { render json: @paramunold.errors, status: :unprocessable_entity }
      end
    end
  end



  # DELETE /paramunolds/1
  # DELETE /paramunolds/1.json
  def destroy
    @paramunold.destroy
    respond_to do |format|
      format.html { redirect_to paramunolds_url, notice: 'Paramunold was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def paramunold_params
      params.require(:paramunold).permit!
    end

end
