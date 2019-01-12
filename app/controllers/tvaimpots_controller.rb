class TvaimpotsController < ApplicationController
  #before_action :set_tvaimpot, only: [:show, :edit, :update, :destroy]

  # GET /tvaimpots
  # GET /tvaimpots.json
  def index
    @tvaimpots = Tvaimpot.all
  end

  # GET /tvaimpots/1
  # GET /tvaimpots/1.json
  def show
  end

  # GET /tvaimpots/new
  def new
    @tvaimpot = Tvaimpot.new
  end

  # GET /tvaimpots/1/edit
  def edit
  end

  # POST /tvaimpots
  # POST /tvaimpots.json
  def create
    @tvaimpot = Tvaimpot.new(tvaimpot_params)

    respond_to do |format|
      if @tvaimpot.save
        format.html { redirect_to @tvaimpot, notice: 'Tvaimpot was successfully created.' }
        format.json { render :show, status: :created, location: @tvaimpot }
      else
        format.html { render :new }
        format.json { render json: @tvaimpot.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tvaimpots/1
  # PATCH/PUT /tvaimpots/1.json
  def update
    respond_to do |format|
      if @tvaimpot.update(tvaimpot_params)
        format.html { redirect_to @tvaimpot, notice: 'Tvaimpot was successfully updated.' }
        format.json { render :show, status: :ok, location: @tvaimpot }
      else
        format.html { render :edit }
        format.json { render json: @tvaimpot.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tvaimpots/1
  # DELETE /tvaimpots/1.json
  def destroy
    @tvaimpot.destroy
    respond_to do |format|
      format.html { redirect_to tvaimpots_url, notice: 'Tvaimpot was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tvaimpot
      @tvaimpot = Tvaimpot.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tvaimpot_params
      params.fetch(:tvaimpot, {})
    end
end
