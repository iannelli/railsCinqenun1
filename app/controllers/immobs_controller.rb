class ImmobsController < ApplicationController

  # TEST de Connexion *******************
  before_action :authenticate_rights
  def authenticate_rights
      dateConnex = params[:parametre][:parDateConnex]
      @paramun = Paramun.find(params[:parametre][:id].to_i)

      if dateConnex.to_i > @paramun.parDateConnex.to_i
          respond_to do |format|
              format.xml { render text: "iimmErreurS" }
          end
      end
  end


  # GET /immobs ****** CHARGEMENT ************************
  # GET /immobs.xml
  def index
      @immobs = @paramun.immobs

      respond_to do |format|
          if @immobs.empty?
               format.xml { render request.format.to_sym => "iimmErreurA" } ## Aucune Immobilisation
          else  
               format.xml { render xml: @immobs }
          end
      end
  end


  # POST /immobs ********* CREATE ******************
  # POST /immobs.xml
  def create
      @current_time = DateTime.now
      current_year = DateTime.now.year
      @immob = Immob.new(immob_params)
      @CreateOK = 0
      begin
          @immob.save
      rescue => e # Incident création de Immob
          @erreur = Erreur.new
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = "rails - ImmobsController - create"
          @erreur.origine = "erreur Création Immob"
          @erreur.numLigne = '41'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:id].to_s
          @erreur.save
          @CreateOK = 1
      end
      if @CreateOK == 0  ## Maj du Nombre de Immob --------------------------
          @nbreImmobArray = @paramun.nbreImmob.split(",")
          anReglement = @immob.dateRegl.slice(6,4) #jj/mm/aaaa
          if anReglement.to_i == current_year.to_i
              nbre = @nbreImmobArray[0].to_i + 1
              @nbreImmobArray[0] = nbre.to_s
          end
          if anReglement.to_i == current_year.to_i-1
              nbre = @nbreImmobArray[1].to_i + 1
              @nbreImmobArray[1] = nbre.to_s
          end
          @paramun.nbreImmob = @nbreImmobArray.join(',')
          begin
              @paramun.save
          rescue => e # Incident save Parametre
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = "rails - ImmobsController - create"
              @erreur.origine = "erreur save Parametre"
              @erreur.numLigne = '66'
              @erreur.message = e.message
              @erreur.parametreId = params[:parametre][:id].to_s
              @erreur.save
              @CreateOK = 2
          end
      end
      if @CreateOK == 0  ## Incidence de l'Immobilisation créée sur la Déclaration de TVA ----------------
          creationLigneTva
      end
      respond_to do |format|
          case @CreateOK
              when 0
                  format.xml { render xml: @immob}
              when 1
                  format.xml { render request.format.to_sym => "iimmErreurC1" }
              when 2
                  format.xml { render request.format.to_sym => "iimmErreurC2" }
          end
      end
  end


  # PUT /immobs/1 ********* MISE A JOUR ******************
  # PUT /immobs/1.xml
  def update
      @current_time = DateTime.now
      @current_year = DateTime.now.year
      @updateOK = 0
      begin
          @immob = Immob.find(params[:id])
      rescue => e # erreur Find Immob
          @erreur = Erreur.new
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = "rails - ImmobsController - update"
          @erreur.origine = "erreur Find Immob - immob.id=" + params[:id].to_s
          @erreur.numLigne = '101'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:id].to_s
          @erreur.save
          @updateOK = 1
      end
      if @updateOK == 0 ## Modification des LigneTva ---- (si problème Find => @updateOK = 2)
          if params[:parametre][:maj].to_s == 'U1' || params[:parametre][:maj].to_s == 'U2'
              @updateOK = modificationLigneTva ## Cf. fin du Controller
          end
      end
      if @updateOK == 0 # Changement de l'année du Règlement ------
          if params[:parametre][:maj].to_s == 'U1' || params[:parametre][:maj].to_s == 'U2'
              @nbreImmobArray = @paramun.nbreImmob.split(",")
              majOK = 0
              if @immob.dateRegl.slice(6,4).to_i > params[:immob][:dateRegl].slice(6,4).to_i # année N / N-1
                  nbre = @nbreImmobArray[0].to_i - 1
                  @nbreImmobArray[0] = nbre.to_s
                  nbre = @nbreImmobArray[1].to_i + 1
                  @nbreImmobArray[1] = nbre.to_s
                  majOK = 1
              end
              if @immob.dateRegl.slice(6,4).to_i < params[:immob][:dateRegl].slice(6,4).to_i # année N-1 / N
                  nbre = @nbreImmobArray[0].to_i + 1
                  @nbreImmobArray[0] = nbre.to_s
                  nbre = @nbreImmobArray[1].to_i - 1
                  @nbreImmobArray[1] = nbre.to_s
                  majOK = 1
              end
              if majOK == 1
                  @paramun.nbreImmob = @nbreImmobArray.join(',')
                  @paramun.save
              end
          end
      end
      if @updateOK == 0
          begin
              @immob.update(immob_params)
          rescue => e # Incident lors de la Maj de Immob
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = "rails - ImmobsController - update"
              @erreur.origine = "erreur Modification Immob - immob.id=" + params[:id].to_s
              @erreur.numLigne = '144'
              @erreur.message = e.message
              @erreur.parametreId = params[:parametre][:id].to_s
              @erreur.save
              @updateOK = 3
          end
      end
      if @updateOK == 0  ## Création des Lignetva -----------
          if params[:parametre][:maj].to_s == 'U1' || params[:parametre][:maj].to_s == 'U2'
              creationLigneTva ## Cf. fin du Controller
          end
      end
      ## FIN du Traitement ------
      respond_to do |format|
          case @updateOK
              when 0
                  format.xml { render request.format.to_sym => "iimmobOK0" }
              when 1
                  format.xml { render request.format.to_sym => "iimmErreurU1" }
              when 2
                  format.xml { render request.format.to_sym => "iimmErreurU2" }
          end
      end
  end



  # DELETE /immobs/1 ********* SUPPRESSION ******************
  # DELETE /immobs/1.xml
  def destroy
      @current_time = DateTime.now
      @current_year = DateTime.now.year
      @destroyOK = 0
      begin
          @immob = Immob.find(params[:id])
      rescue => e # Incident Find Depense
          @erreur = Erreur.new
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = 'rails - ImmobsController - destroy'
          @erreur.origine = "erreur Find Immob - Immob.find(params[:id])=" + params[:id].to_s
          @erreur.numLigne = '184'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:id].to_s
          @erreur.save
          @destroyOK = 1
      end
      if @destroyOK == 0 ## Modification des LigneTva ---- (si problème Find => @destroyOK = 2)
          if @immob.lignesTva.to_s != 'neant'
              @destroyOK = modificationLigneTva ## Cf. fin du Controller
          end
      end
      if @destroyOK == 0 ## Mise à jour du Nombre de Immob
          @nbreImmobArray = @paramun.nbreImmob.split(",")
          if @immob.dateRegl.slice(6,4).to_i == @current_year.to_i
              nbre = @nbreImmobArray[0].to_i - 1
              @nbreImmobArray[0] = nbre.to_s
          end
          if @immob.dateRegl.slice(6,4).to_i == @current_year.to_i - 1
              nbre = @nbreImmobArray[1].to_i - 1
              @nbreImmobArray[1] = nbre.to_s
          end
          @paramun.nbreImmob = @nbreImmobArray.join(',')
          @paramun.save
      end
      if @destroyOK == 0
          begin
              @immob.destroy
          rescue => e # Incident lors de la suppression de Immob
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = 'rails - ImmobsController - destroy'
              @erreur.origine = "erreur Delete Immob - immob.id=" + params[:id].to_s
              @erreur.numLigne = '216'
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
                  format.xml { render request.format.to_sym => "iimmobOK" }
              when 1
                  format.xml { render request.format.to_sym => "iimmErreurD1" }
              when 2
                  format.xml { render request.format.to_sym => "iimmErreurD2" }
              when 3
                  format.xml { render request.format.to_sym => "iimmErreurD3" }
          end
      end
  end



## Création des lignes de la Déclaration de TVA ******************************
  def creationLigneTva
      @arrayImmobId = []
      @ligneArrayImmob = @immob.lignesTva.split("|")
      i = 0
      while i < @ligneArrayImmob.length
          decla = @ligneArrayImmob[i]
          i += 1
          periode = @ligneArrayImmob[i]
          i += 1
          codeLigne = @ligneArrayImmob[i]
          i += 1
          baseHt = @ligneArrayImmob[i].to_i
          i += 1
          tva = @ligneArrayImmob[i].to_i
          i += 1
          @lignetva = Lignetva.where("parametreId = ? AND tvaDecla = ? AND tvaPeriode = ? AND tvaCodeLigne = ?", @paramun.id, decla, periode, codeLigne).first
          if @lignetva.nil?
              @lignetva = Lignetva.new
              @lignetva.tvaDecla = decla
              @lignetva.tvaPeriode = periode
              @lignetva.tvaCodeLigne = codeLigne
              @lignetva.tvaBase = baseHt.to_s
              @lignetva.tvaMontant = tva.to_s
              @lignetva.listeImmobId = @immob.id
              @lignetva.parametreId = @paramun.id
          else
              calTemp = @lignetva.tvaBase.to_i + baseHt
              @lignetva.tvaBase = calTemp.to_s
              calTemp = @lignetva.tvaMontant.to_i + tva
              @lignetva.tvaMontant = calTemp.to_s 
              @arrayImmobId = @lignetva.listeImmobId.split(',')
              @arrayImmobId << @immob.id
              @arrayImmobId.uniq! #Unification des id de même valeur en un seul id
              @lignetva.listeImmobId = @arrayImmobId.join(',')
          end
          @lignetva.save
      end
  end
## FIN Création des lignes de la Déclaration de TVA ****************************

## Modification des lignes de la Déclaration de TVA ******************************
  def modificationLigneTva
      @arrayImmobId = []
      @ligneArrayImmob = @immob.lignesTva.split("|")
      @resultat = 0
      i = 0
      while i < @ligneArrayImmob.length
          decla = @ligneArrayImmob[i]
          i += 1
          periode = @ligneArrayImmob[i]
          i += 1
          codeLigne = @ligneArrayImmob[i]
          i += 1
          baseHt = @ligneArrayImmob[i].to_i
          i += 1
          tva = @ligneArrayImmob[i].to_i
          i += 1
          @lignetva = Lignetva.where("parametreId = ? AND tvaDecla = ? AND tvaPeriode = ? AND tvaCodeLigne = ?", @paramun.id, decla, periode, codeLigne).first
          if @lignetva.nil?
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = "rails - ImmobsController - update"
              @erreur.origine = "erreur Find LigneTva - immob.id=" + params[:id].to_s
              @erreur.numLigne = '248'
              @erreur.message = "@immob.lignesTva = " + @immob.lignesTva.to_s
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
    def immob_params
      params.require(:immob).permit!
    end
end
