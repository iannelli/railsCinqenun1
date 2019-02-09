class LignetvasController < ApplicationController
  before_action :set_lignetva, only: [:show, :edit, :update, :destroy]

  # GET /lignetvas
  # GET /lignetvas.json
  def index
    @lignetvas = Lignetva.all
  end

  # GET /lignetvas/1
  # GET /lignetvas/1.json
  def show
  end

  # GET /lignetvas/new
  def new
    @lignetva = Lignetva.new
  end

  # GET /lignetvas/1/edit
  def edit
  end

  # POST /lignetvas
  # POST /lignetvas.json
  def create
    @lignetva = Lignetva.new(lignetva_params)

    respond_to do |format|
      if @lignetva.save
        format.html { redirect_to @lignetva, notice: 'Lignetva was successfully created.' }
        format.json { render :show, status: :created, location: @lignetva }
      else
        format.html { render :new }
        format.json { render json: @lignetva.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lignetvas/1
  # PATCH/PUT /lignetvas/1.json
  def update
    respond_to do |format|
      if @lignetva.update(lignetva_params)
        format.html { redirect_to @lignetva, notice: 'Lignetva was successfully updated.' }
        format.json { render :show, status: :ok, location: @lignetva }
      else
        format.html { render :edit }
        format.json { render json: @lignetva.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lignetvas/1
  # DELETE /lignetvas/1.json
  def destroy
    @lignetva.destroy
    respond_to do |format|
      format.html { redirect_to lignetvas_url, notice: 'Lignetva was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lignetva
      @lignetva = Lignetva.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def lignetva_params
      params.fetch(:lignetva, {})
    end
end
