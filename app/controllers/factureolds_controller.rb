class FactureoldsController < ApplicationController
  
  # GET /factureolds  ****** CHARGEMENT ************************
  def index
      #@factureolds = Factureold.all
      @projetold = Projetold.find(params[:projetold][:id].to_i)
      @factureolds = @projetold.factureolds

      respond_to do |format|
          if @factureolds.empty?
             format.xml { render request.format.to_sym =>  "ofaErreurA" }  # Aucune Factureold sélectionnée
          else
             format.xml { render xml: @factureolds }
          end
      end
  end

  # POST /factureolds
  def create
    @factureold = Factureold.new(factureold_params)

    if @factureold.save
      redirect_to @factureold, notice: 'Factureold was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /factureolds/1
  def update
    if @factureold.update(factureold_params)
      redirect_to @factureold, notice: 'Factureold was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /factureolds/1
  def destroy
    @factureold.destroy
    redirect_to factureolds_url, notice: 'Factureold was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_factureold
      @factureold = Factureold.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def factureold_params
      params[:factureold]
    end
end
