class TacheoldsController < ApplicationController

  # GET /tacheolds  ****** CHARGEMENT ************************
  def index
      #@tacheolds = Tacheold.all
      @projetold = Projetold.find(params[:projetold][:id].to_i)
      @tacheolds = @projetold.tacheolds

      respond_to do |format|
          if @tacheolds.empty?
             format.xml { render request.format.to_sym => "otaErreurA" }  # Aucune Tacheold sélectionnée
          else
             format.xml { render xml: @tacheolds }
          end
      end
  end

  # POST /tacheolds
  def create
    @tacheold = Tacheold.new(tacheold_params)

    if @tacheold.save
      redirect_to @tacheold, notice: 'Tacheold was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /tacheolds/1
  def update
    if @tacheold.update(tacheold_params)
      redirect_to @tacheold, notice: 'Tacheold was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /tacheolds/1
  def destroy
    @tacheold.destroy
    redirect_to tacheolds_url, notice: 'Tacheold was successfully destroyed.'
  end

  private
    # Only allow a trusted parameter "white list" through.
    def tacheold_params
      params.require(:tacheold).permit!
    end
end
