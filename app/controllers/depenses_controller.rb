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
      @montantDepense = 0
      @depense = Depense.new(depense_params)
      @CreateOK = 0
      @depense.dateEcriture = (@current_time.strftime "%Y-%m-%d-%H-%M").to_s #Date-Heure-Mn 'aaaa-mm-jj-hh-mn'
      begin
          @depense.save
      rescue => e # Incident création de Depense
          @erreur = Erreur.new
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = "1"
          @erreur.origine = "DepensesController[create]: erreur Création Depense"
          @erreur.numLigne = '43'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:id].to_s
          @erreur.save
          @CreateOK = 1
      end
      if @CreateOK == 0  ## Maj de @paramun.nbreDepense et de @paramun.parDepense ------
          @parStatutRegimeArray = @paramun.parStatutRegime.split('|')         
          if @parStatutRegimeArray[3].to_s == 'neant'
              parRegimeTva = @parStatutRegimeArray[1].to_s
          else
             parRegimeTva = @parStatutRegimeArray[5].to_s
          end
          if parRegimeTva.to_i == 0
              @montantDepense = @depense.montantTtc.to_i
          else
              @montantDepense = @depense.montantHt.to_i
          end
          @nbreDepenseArray = @paramun.nbreDepense.split(',')
          @parDepenseArray = @paramun.parDepense.split(',')
          anReglement = @depense.dateRegl.slice(6,4) #jj/mm/aaaa
          if anReglement.to_i == current_year.to_i
              nbre = @nbreDepenseArray[0].to_i + 1
              @nbreDepenseArray[0] = nbre.to_s
              dep = @parDepenseArray[0].to_i + @montantDepense
              @parDepenseArray[0] = dep.to_s
          end
          if anReglement.to_i == current_year.to_i-1
              nbre = @nbreDepenseArray[1].to_i + 1
              @nbreDepenseArray[1] = nbre.to_s
              @nbreDepenseArray[1] = nbre.to_s
              dep = @parDepenseArray[1].to_i + @montantDepense
              @parDepenseArray[1] = dep.to_s
          end
          @paramun.nbreDepense = @nbreDepenseArray.join(',')
          @paramun.parDepense = @parDepenseArray.join(',')
          begin
              @paramun.save
          rescue => e # Incident save Parametre
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = "1"
              @erreur.origine = "DepensesController[create]: erreur save Parametre"
              @erreur.numLigne = '86'
              @erreur.message = e.message
              @erreur.parametreId = params[:parametre][:id].to_s
              @erreur.save
              @CreateOK = 2
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


  # PUT /depenses/1 ********* MISE A JOUR ******************
  # PUT /depenses/1.xml
  def update
      @current_time = DateTime.now
      @current_year = DateTime.now.year
      @montantDepenseOld = 0
      @updateOK = 0
      @majParamOk = 0
      begin
          @depense = Depense.find(params[:id])
          @depense.dateEcriture = (@current_time.strftime "%Y-%m-%d-%H-%M").to_s #Date-Heure-Mn 'aaaa-mm-jj-hh-mn'
          @depense.save
          @parStatutRegimeArray = @paramun.parStatutRegime.split('|')         
          if @parStatutRegimeArray[3].to_s == 'neant'
              parRegimeTva = @parStatutRegimeArray[1].to_s
          else
             parRegimeTva = @parStatutRegimeArray[5].to_s
          end
          if parRegimeTva.to_i == 0
              @montantDepenseOld = @depense.montantTtc.to_i
          else
              @montantDepenseOld = @depense.montantHt.to_i
          end
      rescue => e # erreur Find Depense
          @erreur = Erreur.new
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = "1"
          @erreur.origine = "DepensesController[update]: Find Depense - depense.id=" + params[:id].to_s
          @erreur.numLigne = '121'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:id].to_s
          @erreur.save
          @updateOK = 1
      end

      if @updateOK == 0 # ## Maj de @paramun.nbreDepense et de @paramun.parDepense ------
          @nbreDepenseArray = @paramun.nbreDepense.split(',')
          @parDepenseArray = @paramun.parDepense.split(',')
          # Changement de l'année du Règlement ------ 
          if params[:depense][:dateRegl].slice(6,4).to_i != @depense.dateRegl.slice(6,4).to_i
              if params[:depense][:dateRegl].slice(6,4).to_i == @current_year.to_i
                  nbre = @nbreDepenseArray[0].to_i + 1
                  @nbreDepenseArray[0] = nbre.to_s
                  nbre = @nbreDepenseArray[1].to_i - 1
                  @nbreDepenseArray[1] = nbre.to_s
                  dep = @parDepenseArray[0].to_i + @montantDepenseOld
                  @parDepenseArray[0] = dep.to_s
                  dep = @parDepenseArray[1].to_i - @montantDepenseOld
                  @parDepenseArray[1] = dep.to_s
              end
              if params[:depense][:dateRegl].slice(6,4).to_i == @current_year.to_i - 1
                  nbre = @nbreDepenseArray[0].to_i - 1
                  @nbreDepenseArray[0] = nbre.to_s
                  nbre = @nbreDepenseArray[1].to_i + 1
                  @nbreDepenseArray[1] = nbre.to_s
                  dep = @parDepenseArray[0].to_i - @montantDepenseOld
                  @parDepenseArray[0] = dep.to_s
                  dep = @parDepenseArray[1].to_i + @montantDepenseOld
                  @parDepenseArray[1] = dep.to_s
              end
              @paramun.nbreDepense = @nbreDepenseArray.join(',')
              @paramun.parDepense = @parDepenseArray.join(',')
              @majParamOk = 1
          end
      end
      if @updateOK == 0
          begin
              @depense.update(depense_params)
          rescue => e # Incident lors de la Maj de Depense
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = "1"
              @erreur.origine = "DepensesController[update]: depense.id=" + params[:id].to_s
              @erreur.numLigne = '179'
              @erreur.message = e.message
              @erreur.parametreId = params[:parametre][:id].to_s
              @erreur.save
              @updateOK = 3
          end
      end

      if @updateOK == 0  ## Maj parDepense -----------
          @parStatutRegimeArray = @paramun.parStatutRegime.split('|')         
          if @parStatutRegimeArray[3].to_s == 'neant'
              parRegimeTva = @parStatutRegimeArray[1].to_s
          else
             parRegimeTva = @parStatutRegimeArray[5].to_s
          end
          if parRegimeTva.to_i == 0
              @montantDepense = @depense.montantTtc.to_i
          else
              @montantDepense = @depense.montantHt.to_i
          end
          if params[:parametre][:maj].to_s == 'U2' || params[:parametre][:maj].to_s == 'U3'
              if @montantHtOld.to_i != @depense.montantHt.to_i
                  if @depense.dateRegl.slice(6,4).to_i == @current_year.to_i
                      dep = @parDepenseArray[0].to_i + @montantDepense - @montantDepenseOld
                      @parDepenseArray[0] = dep.to_s
                  end
                  if @depense.dateRegl.slice(6,4).to_i == @current_year.to_i-1
                      dep = @parDepenseArray[1].to_i + @montantDepense - @montantDepenseOld
                      @parDepenseArray[1] = dep.to_s
                  end
                  @paramun.parDepense = @parDepenseArray.join(',')
                  @majParamOk = 1
              end
          end
          if @majParamOk == 1
              @paramun.save
          end
      end
      ## FIN du Traitement ------
      respond_to do |format|
          case @updateOK
              when 0
                  format.xml { render request.format.to_sym => "ddepenseOK0" }
              when 1
                  format.xml { render request.format.to_sym => "ddepErreurU1" }
              when 2
                  format.xml { render request.format.to_sym => "ddepErreurU2" }
              when 3
                  format.xml { render request.format.to_sym => "ddepErreurU3" }
          end
      end
  end


  # DELETE /depenses/1 ********* SUPPRESSION ******************
  # DELETE /depenses/1.xml
  def destroy
      ## Non Utilisé pour des Raisons Comptables et Fisacles
  end


  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def depense_params
      params.require(:depense).permit!
    end
end
