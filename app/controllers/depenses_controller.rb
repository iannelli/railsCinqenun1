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
          @erreur.numLigne = '41'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:id].to_s
          @erreur.save
          @CreateOK = 1
      end
      if @CreateOK == 0  ## Maj du Nombre de Depense --------------------------
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
              @erreur.numLigne = '66'
              @erreur.message = e.message
              @erreur.parametreId = params[:parametre][:id].to_s
              @erreur.save
              @CreateOK = 2
          end
      end
      if @CreateOK == 0  ## Incidence de la dépense créée sur la Déclaration de TVA ----------------
          if @depense.lignesTva.to_s != 'neant'
              creationLigneTva  
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
      @updateOK = 0
      begin
          @depense = Depense.find(params[:id])
      rescue => e # erreur Find Depense
          @erreur = Erreur.new
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = "rails - DepensesController - update"
          @erreur.origine = "erreur Find Depense - depense.id=" + params[:id].to_s
          @erreur.numLigne = '105'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:id].to_s
          @erreur.save
          @updateOK = 1
      end
      if @updateOK == 0 ## Modification des LigneTva ---- (si problème Find : @updateOK = 2)
          if params[:parametre][:maj].to_s == 'U2' || params[:parametre][:maj].to_s == 'U3'
              @updateOK = modificationLigneTva ## Cf. fin du Controller
          end
      end
      if @updateOK == 0 # Changement de l'année du Règlement ------
          if params[:parametre][:maj].to_s == 'U0' || params[:parametre][:maj].to_s == 'U2' || params[:parametre][:maj].to_s == 'U3'
              @nbreDepenseArray = @paramun.nbreDepense.split(",")
              majOK = 0
              if @depense.dateRegl.slice(6,4).to_i > params[:depense][:dateRegl].slice(6,4).to_i #2018 2017
                  nbre = @nbreDepenseArray[0].to_i - 1
                  @nbreDepenseArray[0] = nbre.to_s
                  nbre = @nbreDepenseArray[1].to_i + 1
                  @nbreDepenseArray[1] = nbre.to_s
                  majOK = 1
              end
              if @depense.dateRegl.slice(6,4).to_i < params[:depense][:dateRegl].slice(6,4).to_i #2017 2018
                  nbre = @nbreDepenseArray[0].to_i + 1
                  @nbreDepenseArray[0] = nbre.to_s
                  nbre = @nbreDepenseArray[1].to_i - 1
                  @nbreDepenseArray[1] = nbre.to_s
                  majOK = 1
              end
              if majOK == 1
                  @paramun.nbreDepense = @nbreDepenseArray.join(',')
                  @paramun.save
              end
          end
      end
      if @updateOK == 0
          begin
              @depense.update(depense_params)
          rescue => e # Incident lors de la Maj de Depense
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = "rails - DepensesController - update"
              @erreur.origine = "erreur Modification Depense - depense.id=" + params[:id].to_s
              @erreur.numLigne = '148'
              @erreur.message = e.message
              @erreur.parametreId = params[:parametre][:id].to_s
              @erreur.save
              @updateOK = 3
          end
      end
      if @updateOK == 0  ## Création des Lignetva -----------
          if params[:parametre][:maj].to_s == 'U2' || params[:parametre][:maj].to_s == 'U3'
              creationLigneTva ## Cf. fin du Controller
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
      @current_time = DateTime.now
      @current_year = DateTime.now.year
      @destroyOK = 0
      begin
          @depense = Depense.find(params[:id])
      rescue => e # Incident Find Depense
          @erreur = Erreur.new
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = 'rails - DepensesController - destroy'
          @erreur.origine = "erreur Find Depense - Depense.find(params[:id])=" + params[:id].to_s
          @erreur.numLigne = '192'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:id].to_s
          @erreur.save
          @destroyOK = 1
      end
      if @destroyOK == 0 ## Modification des LigneTva ---- (si problème Find : @destroyOK = 2)
          if @depense.lignesTva.to_s != 'neant'
              @destroyOK = modificationLigneTva ## Cf. fin du Controller
          end
      end
      if @destroyOK == 0 ## Mise à jour du Nombre de Depense
          @nbreDepenseArray = @paramun.nbreDepense.split(",")
          if @depense.dateRegl.slice(6,4).to_i == @current_year.to_i
              nbre = @nbreDepenseArray[0].to_i - 1
              @nbreDepenseArray[0] = nbre.to_s
          end
          if @depense.dateRegl.slice(6,4).to_i == @current_year.to_i - 1
              nbre = @nbreDepenseArray[1].to_i - 1
              @nbreDepenseArray[1] = nbre.to_s
          end
          @paramun.nbreDepense = @nbreDepenseArray.join(',')
          @paramun.save
      end
      if @destroyOK == 0
          begin
              @depense.destroy
          rescue => e # Incident lors de la suppression de Depense
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = 'rails - DepensesController - destroy'
              @erreur.origine = "erreur Delete Depense - depense.id=" + params[:id].to_s
              @erreur.numLigne = '227'
              @erreur.message = e.message
              @erreur.parametreId = params[:parametre][:id].to_s
              @erreur.save
              @destroyOK = 3
          end
      end
      ## FIN du traitement
      respond_to do |format|
          case @destroyOK
              when 0
                  format.xml { render request.format.to_sym => "ddepenseOK" }
              when 1
                  format.xml { render request.format.to_sym => "ddepErreurD1" }
              when 2
                  format.xml { render request.format.to_sym => "ddepErreurD2" }
              when 3
                  format.xml { render request.format.to_sym => "ddepErreurD3" }    
          end
      end
  end


## Création des lignes de la Déclaration de TVA ******************************
  def creationLigneTva
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
## FIN Création des lignes de la Déclaration de TVA ****************************

## Modification des lignes de la Déclaration de TVA ******************************
  def modificationLigneTva
      @arrayDepenseId = []
      @ligneArrayDepense = @depense.lignesTva.split("|")
      @resultat = 0
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
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = "rails - DepensesController - update"
              @erreur.origine = "erreur Find LigneTva - depense.id=" + params[:id].to_s
              @erreur.numLigne = '227'
              @erreur.message = "@depense.lignesTva = " + @depense.lignesTva.to_s
              @erreur.parametreId = params[:parametre][:id].to_s
              @erreur.save
              @resultat = 2
              break
          else
              calTemp = @lignetva.tvaBase.to_i - baseHt
              @lignetva.tvaBase = calTemp.to_s
              calTemp = @lignetva.tvaMontant.to_i - tva
              @lignetva.tvaMontant = calTemp.to_s
              @lignetva.save
          end                    
      end
      return @resultat
  end
## FIN Création/Maj des lignes de la Déclaration de TVA ****************************


  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def depense_params
      params.require(:depense).permit!
    end
end
