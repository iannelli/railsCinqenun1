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
      @typeMaj = ""
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
          @erreur.numLigne = '40'
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
          @paramun.save

          # Création/Maj éventuelle des lignes de la Déclaration de TVA
          # Si Franchise TVA[Perte exonération] ou Régime RSI
          if params[:parametre][:facSituationImpositionTva].to_s == 'A' || params[:parametre][:facSituationImpositionTva].to_s == 'B1'
              if @recette.modePaieLib.to_s != 'imputation crédit'
                  lignetva_create_update_trait
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
              @erreur.numLigne = '106'
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
          @erreur.numLigne = '104'
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
