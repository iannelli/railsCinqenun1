class RecettesController < ApplicationController

  # TEST de Connexion *******************
  before_action :authenticate_rights
  def authenticate_rights
      dateConnex = params[:parametre][:parDateConnex]
      @paramun = Paramun.find(params[:parametre][:id].to_i)
      if dateConnex.to_i > @paramun.parDateConnex.to_i
          respond_to do |format|
              format.xml { render request.format.to_sym => "rrecErreurS" }
          end
      end
  end


  # GET /recettes ****** CHARGEMENT ************************
  # GET /recettes.xml
  def index
      @recettes = @paramun.recettes

      respond_to do |format|
          if @recettes.empty?
               format.xml { render request.format.to_sym => "rrecErreurA" } ## Aucune Recettes
          else
               format.xml { render xml: @recettes }
          end
      end
  end


  # POST /recettes ********* CREATE ****************************************************************
  # POST /recettes.xml
  def create
      @CreateOK = 0
      @recette = Recette.new(recette_params)
      @current_time = DateTime.now
      @current_year = DateTime.now.year
      begin
          @recette.save
      rescue => e # Incident création de Recette
          @erreur = Erreur.new
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = "rails - RecettesController - create"
          @erreur.origine = "erreur Création Recette"
          @erreur.numLigne = '39'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:id].to_s
          @erreur.save
          @CreateOK = 1
      end
      if @CreateOK == 0
          # Mise à jour du nombre d'occurrence de Recette
          @nbreRecetteArray = @paramun.nbreRecette.split(',')
          @parRecetteArray = @paramun.parRecette.split(',')
          @anReception = @recette.facDateReception.slice(6,4) #jj/mm/aaaa
          if @anReception.to_i == @current_year.to_i
              nbre = @nbreRecetteArray[0].to_i + 1
              @nbreRecetteArray[0] = nbre.to_s
              facRegl = @recette.facReglMont.slice(0, @recette.facReglMont.length-2)
              temRecette = @parRecetteArray[0].to_i + facRegl.to_i
              @parRecetteArray[0] = temRecette.to_s
          end
          if @anReception.to_i == @current_year.to_i-1
              nbre = @nbreRecetteArray[1].to_i + 1
              @nbreRecetteArray[1] = nbre.to_s
              facRegl = @recette.facReglMont.slice(0, @recette.facReglMont.length-2)
              temRecette = @parRecetteArray[1].to_i + facRegl.to_i
              @parRecetteArray[1] = temRecette.to_s
          end
          @paramun.nbreRecette = @nbreRecetteArray.join(',')
          @paramun.parRecette = @parRecetteArray.join(',')

          ## Régime de la Franchise TVA : exonération ou perteExonération
          if @paramun.parRegimeTva.to_i < 2
              franchiseTva  # Incidence de la recette créée sur la Franchise TVA
          end

          ## Régime de la Franchise TVA[Perte exonération] ou Option Taxation TVA
          if @paramun.parRegimeTva.to_i > 0
              if params[:ligne][:ligneStringRecette].to_s != 'neant'
                  ligneTva  # Incidence de la recette créée sur la Déclaration de TVA
              end
          end
      end
      respond_to do |format|
          case @CreateOK
              when 0
                  format.xml { render xml: @recette }
              when 1
                  format.xml { render request.format.to_sym => "rrecErreurC1" }
              when 2
                  format.xml { render request.format.to_sym => "rrecErreurC2" }
              when 3
                  format.xml { render request.format.to_sym => "rrecErreurC3" }
          end
      end
  end
## ------ END CREATE **************************************************************************

## Méthodes dédiées à CREATE ********************************************************************
  # Incidence de la création de la recette sur la Franchise TVA
  def franchiseTva
      # Condition d'Application de la Franchise ----
      depass = 0
      case params[:parametre][:parNbreAnActivite].to_i
          when 0 # 1ère année d'activité
              if @parRecetteArray[0].to_i > params[:parametre][:parSeuilMajo].to_i
                  depass = 1 # Mémorisation du mmaaaa du dépassement
              end
          when 1 # 2ème année d'activité
              if @parRecetteArray[1].to_i <= params[:parametre][:parSeuilBase].to_i
                  if @parRecetteArray[0].to_i > params[:parametre][:parSeuilMajo].to_i
                      depass = 1 # Mémorisation du mmaaaa du dépassement
                  end
              else
                  depass = 2 # Imposition TVA sur toute l'année N
              end
          else # au moins 3 années d'activité
              if @parRecetteArray[2].to_i <= params[:parametre][:parSeuilBase].to_i
                  if @parRecetteArray[1].to_i <= params[:parametre][:parSeuilMajo].to_i
                      if @parRecetteArray[0].to_i > params[:parametre][:parSeuilMajo].to_i
                          depass = 1 # Mémorisation du mmaaaa du dépassement
                      end
                  else
                      depass = 2 # Imposition TVA sur toute l'année N
                  end
              else
                  depass = 2 # Imposition TVA sur toute l'année N
              end
      end
      if depass == 0
          @paramun.parDepass = "neant,v"
      else
          @paramun.parRegimeTva = 1
          @paramun.parChoixTauxTva = 0
          @paramun.parDepass = @current_time.strftime("%m") + "/" + @anReception.to_s + ",v"
      end
      begin
          @paramun.save
      rescue => e # Incident save Parametre
          @erreur = Erreur.new
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = "rails - RecettesController - create"
          @erreur.origine = "erreur save Parametre"
          @erreur.numLigne = '134'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:id].to_s
          @erreur.save
          @CreateOK = 2
      end
  end

  # Création/Maj des lignes de la Déclaration de TVA à la suite de la création de l'occurrence de Recette
  def ligneTva
      @arrayRecetteId = []
      @ligneArrayRecette = params[:ligne][:ligneStringRecette].split("|")
      i = 0
      while i < @ligneArrayRecette.length
          decla = @ligneArrayRecette[i]
          i += 1
          periode = @ligneArrayRecette[i]
          i += 1
          codeLigne = @ligneArrayRecette[i]
          i += 1
          baseHt = @ligneArrayRecette[i].to_i
          i += 1
          tva = @ligneArrayRecette[i].to_i
          i += 1
          @lignetva = Lignetva.where("parametreId = ? AND tvaDecla = ? AND tvaPeriode = ? AND tvaCodeLigne = ?", @paramun.id, decla, periode, codeLigne).first
          if @lignetva.nil?
              @lignetva = Lignetva.new
              @lignetva.tvaDecla = decla
              @lignetva.tvaPeriode = periode
              @lignetva.tvaCodeLigne = codeLigne
              @lignetva.tvaBase = baseHt.to_s
              @lignetva.tvaMontant = tva.to_s
              @lignetva.listeRecetteId = @recette.id
              @lignetva.parametreId = @paramun.id
          else
              calTemp = @lignetva.tvaBase.to_i + baseHt
              @lignetva.tvaBase = calTemp.to_s
              calTemp = @lignetva.tvaMontant.to_i + tva
              @lignetva.tvaMontant = calTemp.to_s
              @arrayRecetteId = @lignetva.listeRecetteId.split(',')
              @arrayRecetteId << @recette.id
              @lignetva.listeRecetteId = @arrayRecetteId.join(',')
          end
          @lignetva.save
      end
  end
  ## FIN des Méthodes dédiées à CREATE ********************************************************************



  # PUT /recettes/1 ********* MISE A JOUR **********************************************************
  # PUT /recettes/1.xml *** uniquement pour facDateReception et/ou modePaieLib
  def update
      @current_time = DateTime.now
      @erreurUpdate = 0
      begin
          @recette = Recette.find(params[:id])
          begin
              @recette.update(recette_params)
          rescue => e # Incident Maj de Recette
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = "rails - RecettesController - update"
              @erreur.origine = "erreur Modification Recette.id=" + params[:id].to_s
              @erreur.numLigne = '101'
              @erreur.message = e.message
              @erreur.parametreId = params[:parametre][:id].to_s
              @erreur.save
              @erreurUpdate = 1
          end
      rescue => e # Incident Find Recette
          @erreur = Erreur.new
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = "rails - RecettesController - update"
          @erreur.origine = "Incident Find Recette.id=" + params[:id].to_s
          @erreur.numLigne = '99'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:id].to_s
          @erreur.save
          @erreurUpdate = 1
      end
      respond_to do |format|
          if @erreurUpdate == 0
              format.xml { render request.format.to_sym => "rrecetteOK" }
          else
              format.xml { render request.format.to_sym => "rrecErreurU" }
          end
      end
  end


  # DELETE /recettes/1 ********* SUPPRESSION ******************
  # DELETE /recettes/1.xml ***** Inexistant pour des raisons comptables *****

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def recette_params
      params.require(:recette).permit!
    end
end
