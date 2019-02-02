class DeclaratvasController < ApplicationController
  before_action :set_declaratva, only: [:show, :edit, :update, :destroy]

  # GET /declaratvas
  # GET /declaratvas.json
  def index
    @declaratvas = Declaratva.all
  end

  # GET /declaratvas/1
  # GET /declaratvas/1.json
  def show
  end

  # GET /declaratvas/new
  def new
    @declaratva = Declaratva.new
  end

  # GET /declaratvas/1/edit
  def edit
  end

  # POST /declaratvas
  # POST /declaratvas.json
  def create
    @declaratva = Declaratva.new(declaratva_params)

    respond_to do |format|
      if @declaratva.save
        format.html { redirect_to @declaratva, notice: 'Declaratva was successfully created.' }
        format.json { render :show, status: :created, location: @declaratva }
      else
        format.html { render :new }
        format.json { render json: @declaratva.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /declaratvas/1
  # PATCH/PUT /declaratvas/1.json
  def update
    respond_to do |format|
      if @declaratva.update(declaratva_params)
        format.html { redirect_to @declaratva, notice: 'Declaratva was successfully updated.' }
        format.json { render :show, status: :ok, location: @declaratva }
      else
        format.html { render :edit }
        format.json { render json: @declaratva.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /declaratvas/1
  # DELETE /declaratvas/1.json
  def destroy
    @declaratva.destroy
    respond_to do |format|
      format.html { redirect_to declaratvas_url, notice: 'Declaratva was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_declaratva
      @declaratva = Declaratva.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def declaratva_params
      params.fetch(:declaratva, {})
    end
end
