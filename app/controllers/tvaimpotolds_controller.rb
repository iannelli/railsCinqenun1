class TvaimpotoldsController < ApplicationController
  before_action :set_tvaimpotold, only: [:show, :edit, :update, :destroy]

  # GET /tvaimpotolds
  # GET /tvaimpotolds.json
  def index
    @tvaimpotolds = Tvaimpotold.all
  end

  # GET /tvaimpotolds/1
  # GET /tvaimpotolds/1.json
  def show
  end

  # GET /tvaimpotolds/new
  def new
    @tvaimpotold = Tvaimpotold.new
  end

  # GET /tvaimpotolds/1/edit
  def edit
  end

  # POST /tvaimpotolds
  # POST /tvaimpotolds.json
  def create
    @tvaimpotold = Tvaimpotold.new(tvaimpotold_params)

    respond_to do |format|
      if @tvaimpotold.save
        format.html { redirect_to @tvaimpotold, notice: 'Tvaimpotold was successfully created.' }
        format.json { render :show, status: :created, location: @tvaimpotold }
      else
        format.html { render :new }
        format.json { render json: @tvaimpotold.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tvaimpotolds/1
  # PATCH/PUT /tvaimpotolds/1.json
  def update
    respond_to do |format|
      if @tvaimpotold.update(tvaimpotold_params)
        format.html { redirect_to @tvaimpotold, notice: 'Tvaimpotold was successfully updated.' }
        format.json { render :show, status: :ok, location: @tvaimpotold }
      else
        format.html { render :edit }
        format.json { render json: @tvaimpotold.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tvaimpotolds/1
  # DELETE /tvaimpotolds/1.json
  def destroy
    @tvaimpotold.destroy
    respond_to do |format|
      format.html { redirect_to tvaimpotolds_url, notice: 'Tvaimpotold was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tvaimpotold
      @tvaimpotold = Tvaimpotold.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tvaimpotold_params
      params.fetch(:tvaimpotold, {})
    end
end
