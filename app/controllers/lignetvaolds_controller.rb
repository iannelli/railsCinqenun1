class LignetvaoldsController < ApplicationController
  before_action :set_lignetvaold, only: [:show, :edit, :update, :destroy]

  # GET /lignetvaolds
  # GET /lignetvaolds.json
  def index
    @lignetvaolds = Lignetvaold.all
  end

  # GET /lignetvaolds/1
  # GET /lignetvaolds/1.json
  def show
  end

  # GET /lignetvaolds/new
  def new
    @lignetvaold = Lignetvaold.new
  end

  # GET /lignetvaolds/1/edit
  def edit
  end

  # POST /lignetvaolds
  # POST /lignetvaolds.json
  def create
    @lignetvaold = Lignetvaold.new(lignetvaold_params)

    respond_to do |format|
      if @lignetvaold.save
        format.html { redirect_to @lignetvaold, notice: 'Lignetvaold was successfully created.' }
        format.json { render :show, status: :created, location: @lignetvaold }
      else
        format.html { render :new }
        format.json { render json: @lignetvaold.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lignetvaolds/1
  # PATCH/PUT /lignetvaolds/1.json
  def update
    respond_to do |format|
      if @lignetvaold.update(lignetvaold_params)
        format.html { redirect_to @lignetvaold, notice: 'Lignetvaold was successfully updated.' }
        format.json { render :show, status: :ok, location: @lignetvaold }
      else
        format.html { render :edit }
        format.json { render json: @lignetvaold.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lignetvaolds/1
  # DELETE /lignetvaolds/1.json
  def destroy
    @lignetvaold.destroy
    respond_to do |format|
      format.html { redirect_to lignetvaolds_url, notice: 'Lignetvaold was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lignetvaold
      @lignetvaold = Lignetvaold.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def lignetvaold_params
      params.fetch(:lignetvaold, {})
    end
end
