class ErreursController < ApplicationController
  #before_action :set_erreur, only: [:show, :edit, :update, :destroy]

  # GET /erreurs
  def index
    @erreurs = Erreur.all
  end


  # POST /erreurs
  def create
    @erreur = Erreur.new(erreur_params)

    if @erreur.save
      redirect_to @erreur, notice: 'Erreur was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /erreurs/1
  def update
    if @erreur.update(erreur_params)
      redirect_to @erreur, notice: 'Erreur was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /erreurs/1
  def destroy
    @erreur.destroy
    redirect_to erreurs_url, notice: 'Erreur was successfully destroyed.'
  end

  private
    # Only allow a trusted parameter "white list" through.
    def erreur_params
      params.require(:erreur).permit!
    end

end
