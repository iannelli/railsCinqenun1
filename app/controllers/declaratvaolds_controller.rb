class DeclaratvaoldsController < ApplicationController
  before_action :set_declaratvaold, only: [:show, :edit, :update, :destroy]

  # GET /declaratvaolds
  # GET /declaratvaolds.json
  def index
    @declaratvaolds = Declaratvaold.all
  end

  # GET /declaratvaolds/1
  # GET /declaratvaolds/1.json
  def show
  end

  # GET /declaratvaolds/new
  def new
    @declaratvaold = Declaratvaold.new
  end

  # GET /declaratvaolds/1/edit
  def edit
  end

  # POST /declaratvaolds
  # POST /declaratvaolds.json
  def create
    @declaratvaold = Declaratvaold.new(declaratvaold_params)

    respond_to do |format|
      if @declaratvaold.save
        format.html { redirect_to @declaratvaold, notice: 'Declaratvaold was successfully created.' }
        format.json { render :show, status: :created, location: @declaratvaold }
      else
        format.html { render :new }
        format.json { render json: @declaratvaold.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /declaratvaolds/1
  # PATCH/PUT /declaratvaolds/1.json
  def update
    respond_to do |format|
      if @declaratvaold.update(declaratvaold_params)
        format.html { redirect_to @declaratvaold, notice: 'Declaratvaold was successfully updated.' }
        format.json { render :show, status: :ok, location: @declaratvaold }
      else
        format.html { render :edit }
        format.json { render json: @declaratvaold.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /declaratvaolds/1
  # DELETE /declaratvaolds/1.json
  def destroy
    @declaratvaold.destroy
    respond_to do |format|
      format.html { redirect_to declaratvaolds_url, notice: 'Declaratvaold was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_declaratvaold
      @declaratvaold = Declaratvaold.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def declaratvaold_params
      params.fetch(:declaratvaold, {})
    end
end
