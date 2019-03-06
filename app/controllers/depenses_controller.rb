class DepensesController < ApplicationController

  # TEST de Connexion *******************
  before_action :authenticate_rights
  def authenticate_rights
      dateConnex = params[:parametre][:parDateConnex]
      @paramun = Paramun.find(params[:parametre][:id].to_i)

      if dateConnex.to_i > @paramun.parDateConnex.to_i
          respond_to do |format|
              format.xml { render text: "ddepErreurS" }
          end
      end
  end


  # GET /depenses ****** CHARGEMENT ************************
  # GET /depenses.xml
  def index
      @depenses = @paramun.depenses

      respond_to do |format|
          if @depenses.empty?
               format.xml { render request.format.to_sym => "ddepErreurA" } ## Aucune Depense
          else  
               format.xml { render xml: @depenses }
          end
      end
  end



  # POST /depenses ********* CREATE ******************
  # POST /depenses.xml
  def create
      @current_time = DateTime.now
      current_year = DateTime.now.year
      @depense = Depense.new(depense_params)
      @CreateOK = 0
      begin
          @depense.save
      rescue => e # Incident création de Depense
          @erreur = Erreur.new
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = "rails - DepensesController - create"
          @erreur.origine = "erreur Création Depense"
          @erreur.numLigne = '39'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:id].to_s
          @erreur.save
          @CreateOK = 1
      end
      if @CreateOK == 0
          @nbreDepenseArray = @paramun.nbreDepense.split(",")
          anReglement = @depense.dateRegl.slice(6,4) #jj/mm/aaaa
          if anReglement.to_i == current_year.to_i
              nbre = @nbreDepenseArray[0].to_i + 1
              @nbreDepenseArray[0] = nbre.to_s
          end
          if anReglement.to_i == current_year.to_i-1
              nbre = @nbreDepenseArray[1].to_i + 1
              @nbreDepenseArray[1] = nbre.to_s
          end
          @paramun.nbreDepense = @nbreDepenseArray.join(',')
          begin
              @paramun.save
          rescue => e # Incident save Parametre
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = "rails - DepensesController - create"
              @erreur.origine = "erreur save Parametre"
              @erreur.numLigne = '57'
              @erreur.message = e.message
              @erreur.parametreId = params[:parametre][:id].to_s
              @erreur.save
              @CreateOK = 2
          end
      end
      if @CreateOK == 0
          if @paramun.parRegimeTva.to_i > 0 ## Régime de la Franchise TVA[Perte exonération] ou Régime RSI
              if @depense.typeDecla.to_s != 'E'  ## Ligne à remplir pour les Déclarations autre que de type 'E'
                  ligneTva  # Incidence de la dépense créée sur la Déclaration de TVA
              end
          end
      end
      respond_to do |format|
          case @CreateOK
              when 0
                  format.xml { render xml: @depense}
              when 1
                  format.xml { render request.format.to_sym => "ddepErreurC1" }
              when 2
                  format.xml { render request.format.to_sym => "ddepErreurC2" }
          end
      end
  end

## Méthode dédiée à CREATE ********************************************************************
## Création/Maj des lignes de la Déclaration de TVA à la suite de la création de l'occurrence de Depense
  def ligneTva
      @arrayDepenseId = []
      @ligneArrayDepense = @depense.lignesTva.split("|")
      i = 0
      while i < @ligneArrayDepense.length
          decla = @ligneArrayDepense[i]
          i += 1
          periode = @ligneArrayDepense[i]
          i += 1
          codeLigne = @ligneArrayDepense[i]
          i += 1
          baseHt = @ligneArrayDepense[i].to_i
          i += 1
          tva = @ligneArrayDepense[i].to_i
          i += 1
          @lignetva = Lignetva.where("parametreId = ? AND tvaDecla = ? AND tvaPeriode = ? AND tvaCodeLigne = ?", @paramun.id, decla, periode, codeLigne).first
          if @lignetva.nil?
              @lignetva = Lignetva.new
              @lignetva.tvaDecla = decla
              @lignetva.tvaPeriode = periode
              @lignetva.tvaCodeLigne = codeLigne
              @lignetva.tvaBase = baseHt.to_s
              @lignetva.tvaMontant = tva.to_s
              @lignetva.listeDepenseId = @depense.id
              @lignetva.parametreId = @paramun.id
          else
              calTemp = @lignetva.tvaBase.to_i + baseHt
              @lignetva.tvaBase = calTemp.to_s
              calTemp = @lignetva.tvaMontant.to_i + tva
              @lignetva.tvaMontant = calTemp.to_s 
              @arrayDepenseId = @lignetva.listeDepenseId.split(',')
              @arrayDepenseId << @depense.id
              @lignetva.listeDepenseId = @arrayDepenseId.join(',')
          end
          @lignetva.save
      end
  end
## FIN des Méthodes dédiées à CREATE ********************************************************************



  # PUT /depenses/1 ********* MISE A JOUR ******************
  # PUT /depenses/1.xml
  ## Maj SANS conséquence sur la TVA ---
  def update
      @current_time = DateTime.now
      @current_year = DateTime.now.year
      @updateOK = 0
      begin
          @depense = Depense.find(params[:id])
      rescue => e # erreur Find Depense
          @erreur = Erreur.new
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = "rails - DepensesController - update"
          @erreur.origine = "erreur Find Depense - depense.id=" + params[:id].to_s
          @erreur.numLigne = '147'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:id].to_s
          @erreur.save
          @updateOK = 1
      end
      if @updateOK == 0
          begin
              @depense.update(depense_params)
          rescue => e # Incident lors de la Maj de Depense
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = "rails - DepensesController - update"
              @erreur.origine = "erreur Modification Depense - depense.id=" + params[:id].to_s
              @erreur.numLigne = '91'
              @erreur.message = e.message
              @erreur.parametreId = params[:parametre][:id].to_s
              @erreur.save
              @updateOK = 2
          end
      end
      if @updateOK == 0
          if params[:parametre][:changeAnRegl].to_s != '0'
              @nbreDepenseArray = @paramun.nbreDepense.split(",")
              if params[:parametre][:changeAnRegl].to_s == '2' # Changement de l'année du Règlement anPrécédent --> AnCourant
                  nbre = @nbreDepenseArray[0].to_i + 1
                  @nbreDepenseArray[0] = nbre.to_s
                  nbre = @nbreDepenseArray[1].to_i - 1
                  @nbreDepenseArray[1] = nbre.to_s
              end
              if params[:parametre][:changeAnRegl].to_s == '1' # Changement de l'année du Règlement AnCourant --> anPrécédent
                  nbre = @nbreDepenseArray[0].to_i - 1
                  @nbreDepenseArray[0] = nbre.to_s
                  nbre = @nbreDepenseArray[1].to_i + 1
                  @nbreDepenseArray[1] = nbre.to_s
              end
              @paramun.nbreDepense = @nbreDepenseArray.join(',')
              @paramun.save
          end
      end
      respond_to do |format|
          case @updateOK
              when 0
                  format.xml { render request.format.to_sym => "ddepenseOK0" }
              when 1
                  format.xml { render request.format.to_sym => "ddepErreurU1" }
              when 2
                  format.xml { render request.format.to_sym => "ddepErreurU2" }
          end
      end
  end



  # DELETE /depenses/1 ********* SUPPRESSION ******************
  # DELETE /depenses/1.xml
  def destroy
      @current_time = DateTime.now
      @destroyOK = 0
      begin
          @depense = Depense.find(params[:id])
      rescue => e # Incident Find Depense
          @erreur = Erreur.new
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = 'rails - DepensesController - destroy'
          @erreur.origine = "erreur Find Depense - Depense.find(params[:id])=" + params[:id].to_s
          @erreur.numLigne = '310'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:id].to_s
          @erreur.save
          @destroyOK = 1
      end
      if @destroyOK == 0
          begin
              @depense.destroy
          rescue => e # Incident lors de la suppression de Depense
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = 'rails - DepensesController - destroy'
              @erreur.origine = "erreur Delete Depense - depense.id=" + params[:id].to_s
              @erreur.numLigne = '324'
              @erreur.message = e.message
              @erreur.parametreId = params[:parametre][:id].to_s
              @erreur.save
              @destroyOK = 2
          end
      end
      if @destroyOK == 0
          @nbreDepenseArray = @paramun.nbreDepense.split(",")
          nbre = @nbreDepenseArray[0].to_i - 1
          @nbreDepenseArray[0] = nbre.to_s
          @paramun.nbreDepense = @nbreDepenseArray.join(',')
          begin
              @paramun.save
          rescue => e # Incident save Parametre
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = "rails - DepensesController - create"
              @erreur.origine = "erreur save Parametre"
              @erreur.numLigne = '343'
              @erreur.message = e.message
              @erreur.parametreId = params[:parametre][:id].to_s
              @erreur.save
              @destroyOK = 3
          end
      end
      respond_to do |format|
          case @destroyOK
              when 0
                  format.xml { render request.format.to_sym => "ddepenseOK" }
              when 1
                  format.xml { render request.format.to_sym => "ddepErreurD1" }
              when 2
                  format.xml { render request.format.to_sym => "ddepErreurD2" }
          end
      end
  end


  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def depense_params
      params.require(:depense).permit!
    end
end
