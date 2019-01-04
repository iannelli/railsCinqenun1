class FacturesController < ApplicationController

  @@origine = ""

  # TEST de Connexion *******************
  before_action :authenticate_rights
  def authenticate_rights
      dateConnex = params[:parametre][:parDateConnex]
      @paramun = Paramun.find(params[:parametre][:id].to_i)

      if dateConnex.to_i > @paramun.parDateConnex.to_i
          respond_to do |format|
              format.xml { render request.format.to_sym => "ffacErreurS" }
          end
      end
  end
  
  
  
  # GET /factures ****** CHARGEMENT ************************
  # GET /factures.xml
  def index
      @projet = Projet.find(params[:projet][:id])
      @factures = @projet.factures

      respond_to do |format|
          if @factures.empty?
              format.xml { render request.format.to_sym => "ffacErreurA" }  # Aucune Facture collectée
          else        
              format.xml { render xml: @factures }
          end
      end
  end


  # POST /factures ********* CREATE FACTURE ************************************************************************
  # POST /factures.xml
  def create
      @current_time = DateTime.now
      @@origine = 'C'
      @erreurCreate = 0
      ## Vérification de l'absence de "doublon" pour le type d'Imprimé créé
      begin
          @projet = Projet.find(params[:projet][:id])
          if @projet.factures.length > 0
              @projet.factures.each do |facture|
                  if facture.typeImpr.to_s == params[:facture][:typeImpr].to_s
                      if ['10', '11', '20', '50', '51'].include? facture.typeImpr.to_s
                          @erreurCreate = 2
                          break
                      end
                  end
              end
          end
      rescue => e  # Incident Find Projet
          @erreur = Erreur.new
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = "rails - FacturesController - create"
          @erreur.origine = "erreur Find Projet.find(params[:projet][:id])=" + params[:projet][:id].to_s
          @erreur.numLigne = '43'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:id].to_s
          @erreur.save
          @erreurCreate = 1
      end

      if @erreurCreate == 0
          ## Mise à jour éventuelle de période de tache(tacFacString) avant de débuter le traitement de facturation
          if params[:tache][:tacFacString].to_s != "neant" # nonConcerné la Création/Annulation d'un BdC ou d'une Facture d'Acompte
              @tacFacArray = params[:tache][:tacFacString].split(",")
              t = 0
              while (t < @tacFacArray.length)
                  tacFacElementArray = @tacFacArray[t].split('|')
                  begin
                      @tache = Tache.find(tacFacElementArray[0].to_i)
                      @tache.tacFacString = @tacFacArray[t].to_s
                      begin
                          @tache.save
                          t += 1
                      rescue => e  # Incident MAJ Tache
                          @erreur = Erreur.new
                          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                          @erreur.appli = "rails - FacturesController - create"
                          @erreur.origine = "erreur Maj Periode tache - @tache.id=" + @tache.id.to_s
                          @erreur.numLigne = '77'
                          @erreur.message = e.message
                          @erreur.parametreId = params[:parametre][:id].to_s
                          @erreur.save
                          @erreurCreate = 1
                          break
                      end
                  rescue => e  # Incident Find Tache
                      @erreur = Erreur.new
                      @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                      @erreur.appli = "rails - FacturesController - create"
                      @erreur.origine = "erreur Maj Find tache - tacFacElementArray=" + tacFacElementArray.to_s
                      @erreur.numLigne = '74'
                      @erreur.message = e.message
                      @erreur.parametreId = params[:parametre][:id].to_s
                      @erreur.save
                      @erreurCreate = 1
                      break
                  end
              end
          end
          if @erreurCreate == 0
              @majTache = []
              @indMajTache = 0
              @proNumRangArray = @projet.proNumRang.split("|")
              @facture = Facture.new(facture_params)
              @facture.projetId = @projet.id.to_i
              begin
                  @facture.save
                  case @facture.typeImpr.to_s ## Mise à Jour du Projet correspondant ------
                      when '10'
                          @proNumRangArray[0] = @facture.id
                          numRang = @proNumRangArray[1].to_i
                          numRang += 1
                          @proNumRangArray[1] = numRang
                      when '11'
                          @proNumRangArray[2] = @facture.id
                          numRang = @proNumRangArray[3].to_i
                          numRang += 1
                          @proNumRangArray[3] = numRang
                      when '20', '40', '50'
                          numRang = @proNumRangArray[1].to_i
                          numRang += 1
                          @proNumRangArray[1] = numRang
                      when '21', '41', '51'
                          numRang = @proNumRangArray[3].to_i
                          numRang += 1
                          @proNumRangArray[3] = numRang
                      when '60'
                          numRang = @proNumRangArray[1].to_i
                          numRang -= 1
                          @proNumRangArray[1] = numRang
                      when '61'
                          numRang = @proNumRangArray[3].to_i
                          numRang -= 1
                          @proNumRangArray[3] = numRang
                  end
                  @projet.proNumRang = @proNumRangArray.join('|')
                  @projet.proCliString = params[:projet][:proCliString]
                  @projet.proSuiviFac = params[:projet][:proSuiviFac]
                  if params[:projet][:proCaHt].to_s != "neant"
                      @projet.proCaHt = params[:projet][:proCaHt]
                      @projet.proFacHt = params[:projet][:proFacHt]
                      @projet.proMarge = params[:projet][:proMarge]
                      @projet.proReglMont = params[:projet][:proReglMont]
                      @projet.proReport = params[:projet][:proReport]
                      @projet.majDate = params[:projet][:majDate]
                  end
                  begin
                      @projet.save
                      ## Autres MAJ -----
                      case @facture.typeImpr.to_s
                          when '20', '21' ##-- Facture Acompte ---
                              updateParametreNumFact ## MAJ Identité (Numéro de Facture)
                          when '40', '50', '41', '51' ##-- Facture Intermédiaire et Solde ---
                              updateParametreNumFact ## MAJ Identité (Numéro de Facture)
                              if @erreurCreate == 0
                                  updateTacFacString  ## MAJ Tache (Statut et factureId)
                              end
                          when '60', '61' ##-- Facture Avoir  ---
                              updateParametreNumFact ## MAJ Identité (Numéro de Facture)
                              if @erreurCreate == 0
                                  if params[:tache][:tacFacString].to_s != "neant"
                                      updateTacFacString  ## MAJ Tache (Statut et factureId) : ne concerne pas la création/annulation d'une Facture d'Acompte
                                  end
                                  ## MAJ du Statut de la facture Annulée si créationFacture Avoir ******
                                  begin
                                      @factAnnul = Facture.find(params[:factannul][:id])
                                      @factAnnul.facStatut = "3Annulé"
                                      @factAnnul.facMention = "**** Facture Annulée ****"
                                      begin
                                          @factAnnul.save
                                      rescue => e  # Incident Save Facture annulée
                                          @erreur = Erreur.new
                                          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                                          @erreur.appli = "rails - FacturesController - create"
                                          @erreur.origine = "erreur Save Facture annulée - params[:factannul][:id]=" + params[:factannul][:id].to_s
                                          @erreur.numLigne = '174'
                                          @erreur.message = e.message
                                          @erreur.parametreId = params[:parametre][:id].to_s
                                          @erreur.save
                                          @erreurCreate = 1
                                      end
                                  rescue => e  # Incident Find Facture annulée
                                      @erreur = Erreur.new
                                      @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                                      @erreur.appli = "rails - FacturesController - create"
                                      @erreur.origine = "erreur Find Facture annulée - params[:factannul][:id]=" + params[:factannul][:id].to_s
                                      @erreur.numLigne = '170'
                                      @erreur.message = e.message
                                      @erreur.parametreId = params[:parametre][:id].to_s
                                      @erreur.save
                                      @erreurCreate = 1
                                  end
                              end
                      end
                      ## FIN Autres MAJ -----
                      ## MAJ témoin de MAJ ---
                      if @erreurCreate == 0
                          @facture.majTache = @majTache.join(',')
                          begin
                              @facture.save
                          rescue => e  # Incident Save Facture
                              @erreur = Erreur.new
                              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                              @erreur.appli = "rails - FacturesController - create"
                              @erreur.origine = "erreur Maj Facture @facture.id=" + @facture.id.to_s
                              @erreur.numLigne = '205'
                              @erreur.message = e.message
                              @erreur.parametreId = params[:parametre][:id].to_s
                              @erreur.save
                              @erreurCreate = 1
                          end
                      end
                  rescue => e  # Incident Save Projet
                      @erreur = Erreur.new
                      @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                      @erreur.appli = "rails - FacturesController - create"
                      @erreur.origine = "erreur Maj Projet @projet.id=" + @projet.id.to_s
                      @erreur.numLigne = '153'
                      @erreur.message = e.message
                      @erreur.parametreId = params[:parametre][:id].to_s
                      @erreur.save
                      @erreurCreate = 1
                  end
              rescue => e  # Incident Save Facture
                  @erreur = Erreur.new
                  @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                  @erreur.appli = "rails - FacturesController - create"
                  @erreur.origine = "erreur Maj Facture"
                  @erreur.numLigne = '112'
                  @erreur.message = e.message
                  @erreur.parametreId = params[:parametre][:id].to_s
                  @erreur.save
                  @erreurCreate = 1
              end
          end
    end
    respond_to do |format|
        case @erreurCreate
          when 0
              format.xml { render xml: @facture }
          when 1
              format.xml { render request.format.to_sym => "ffacErreurC1" }
          when 2
              format.xml { render request.format.to_sym => "ffacErreurC2" }
        end
    end # End Respond Format -----
  end
## ------ END CREATE **************************************************************************


## Méthodes communes à CREATE et UPDATE *******************************************************
  #  MISE A JOUR du dernier Numéro de facture ---------
  def updateParametreNumFact
      @current_time = DateTime.now
      begin
          @paramun = Paramun.find(params[:parametre][:id].to_i)
          @paramun.parNumFact = params[:parametre][:parNumFact].to_s
          @paramun.save
      rescue => e  # Incident Maj Parametre
          @erreur = Erreur.new
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          if @@origine == 'C'
              @erreur.appli = "rails - FacturesController - create"
              @erreurCreate = 1
          else
              @erreur.appli = "rails - FacturesController - update"
              @erreurUpdate = 1
          end
          @erreur.origine = "erreur Maj Parametre - def updateParametreNumFact"
          @erreur.numLigne = '261'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:id].to_s
          @erreur.save
      end
  end

 ##  MISE A JOUR des Tache.tacFacString et Tache.statut --------------
  def updateTacFacString
      t = 0
      ## A partir de @tacFacArray (Facture0.paramTacheTacFacString0) MAJ de Tache.tacFacString et de Facture.majTache
      while (t < @tacFacArray.length)
          tacFacElementArray = @tacFacArray[t].split('|')
          e = 0
          while (e < tacFacElementArray.length)
              if params[:operation][:maj] == 'C'
                  if (tacFacElementArray[e+2].to_s == 'F' && tacFacElementArray[e+4].to_s == '.')
                     tacFacElementArray[e+4] = @facture.id
                  end
                  if (tacFacElementArray[e+2].to_s == 'L')
                     tacFacElementArray[e+2] = '.'
                     tacFacElementArray[e+3] = '.'
                     tacFacElementArray[e+4] = '.'
                  end
              end
              if params[:operation][:maj] == 'R'
                  if (tacFacElementArray[e+2].to_s == 'F' && tacFacElementArray[e+4].to_i == @facture.id)
                     tacFacElementArray[e+2] = 'R'
                  end
              end
              e += 5
          end
          begin
              @tache = Tache.find(tacFacElementArray[0].to_i)
              totalTacheHt = 0
              nbrePeriodeFacturee = 0 # Nombre de période au Statut "Facturé"
              nbrePeriodeReglee = 0 # Nombre de période au Statut "Réglé"
              e = 0
              while (e < tacFacElementArray.length)
                  if tacFacElementArray[e+3] != "." ## montHt
                      totalTacheHt += tacFacElementArray[e+3].to_i
                  end
                  if tacFacElementArray[e+2] == "F"
                      nbrePeriodeFacturee += 1
                  end
                  if tacFacElementArray[e+2] == "R"
                      nbrePeriodeReglee += 1
                  end
                  e += 5
              end
              max = tacFacElementArray.length / 5
              if nbrePeriodeReglee == max
                  @tache.tacStatut = "3Réglé"
              end
              if nbrePeriodeFacturee == max
                  @tache.tacStatut = "3Facturé"
              end
              if nbrePeriodeFacturee > 0 && nbrePeriodeFacturee < max
                  @tache.tacStatut = "3miFacturé"
              end
              if nbrePeriodeFacturee == 0 && nbrePeriodeReglee == 0
                  @tache.tacStatut = "0enCours"
              end
              @tache.tacFacString = tacFacElementArray.join('|')
              @tache.tacFacHt = totalTacheHt
              @tache.tacMarge = totalTacheHt - @tache.tacCout.to_i
              begin
                  @tache.save
                  ## Création de Facture.majTache ------
                  @majTache[@indMajTache] = @tache.id
                  @indMajTache += 1
                  @majTache[@indMajTache] = @tache.tacFacString
                  @indMajTache += 1
                  @majTache[@indMajTache] = @tache.tacStatut
                  @indMajTache += 1
                  @majTache[@indMajTache] = totalTacheHt
                  @indMajTache += 1
                  t += 1
              rescue => e  # Incident Save Tache
                  @erreur = Erreur.new
                  current_time = DateTime.now
                  @erreur.dateHeure = current_time.strftime "%d/%m/%Y %H:%M:%S"
                  if @@origine == 'C'
                      @erreur.appli = "rails - FacturesController - create"
                      @erreurCreate = 1
                  else
                      @erreur.appli = "rails - FacturesController - update"
                      @erreurUpdate = 1
                  end
                  @erreur.origine = "erreur Save Tache - @tache.id=" + @tache.id.to_s
                  @erreur.numLigne = '340'
                  @erreur.message = e.message
                  @erreur.parametreId = params[:parametre][:id].to_s
                  @erreur.save
                  break
              end
          rescue => e  # Incident Find Tache
              @erreur = Erreur.new
              current_time = DateTime.now
              @erreur.dateHeure = current_time.strftime "%d/%m/%Y %H:%M:%S"
              if @@origine == 'C'
                  @erreur.appli = "rails - FacturesController - Create - updateTacFacString"
                  @erreurCreate = 1
              else
                  @erreur.appli = "rails - FacturesController - Update - updateTacFacString"
                  @erreurUpdate = 1
              end
              @erreur.origine = "erreur Find Tache - tacFacElementArray[0]=" + tacFacElementArray[0].to_s
              @erreur.numLigne = '306'
              @erreur.message = e.message
              @erreur.parametreId = params[:parametre][:id].to_s
              @erreur.save
              break
          end
      end ## end while ---
  end
## FIN des méthodes communes à CREATE et UPDATE ****************************************



## PUT /factures/1 ********* MISE A JOUR FACTURE **********************************************************************
  # PUT /factures/1.xml
  def update
      @current_time = DateTime.now
      @@origine = 'U'
      @erreurUpdate = 0
      begin
          @facture = Facture.find(params[:id])
          @majTache = []
          @indMajTache = 0
          @tacFacArray  = []
      rescue => e  # Incident Find Facture
          @erreur = Erreur.new
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = "rails - FacturesController - update"
          @erreur.origine = "erreur Find Facture - Facture.find(params[:id])=" + params[:id].to_s
          @erreur.numLigne = '400'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:id].to_s
          @erreur.save
          @erreurUpdate = 1
      end
      if @erreurUpdate == 0
          begin
              @facture.update(facture_params) ## Mise à jour du BdC/Facture
              if params[:operation][:maj] == 'R' && @facture.typeImpr.slice(0,1) != '1' ## Complément si Règlement du BdC/facture
                  @majTache = @facture.majTache.split(',')
                  e = 0
                  while (e < @majTache.length)
                      @tacFacArray.push(@majTache[e+1])
                      e += 4
                  end
                  updateTacFacString  ## MAJ Tache (Statut et tacFacString)
                  if @erreurUpdate == 0
                      @facture.majTache = @majTache.join(',')
                      begin
                          @facture.save
                      rescue => e  # Incident Save Facture
                          @erreur = Erreur.new
                          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                          @erreur.appli = "rails - FacturesController - update"
                          @erreur.origine = "erreur Save Facture - @facture.id=" + @facture.id.to_s
                          @erreur.numLigne = '429'
                          @erreur.message = e.message
                          @erreur.parametreId = params[:parametre][:id].to_s
                          @erreur.save
                          @erreurUpdate = 1
                      end
                  end
              end
              if @erreurUpdate == 0
                  if params[:projet][:id].to_s != "neant"
                      begin
                          @projet = Projet.find(params[:projet][:id])
                          @projet.proSuiviFac = params[:projet][:proSuiviFac]
                          @projet.proSituation = params[:projet][:proSituation]
                          @projet.proReglMont = params[:projet][:proReglMont]
                          @projet.proReport = params[:projet][:proReport]
                          @projet.majDate = params[:projet][:majDate]
                          begin
                              @projet.save
                          rescue => e  # Incident Save Projet
                              @erreur = Erreur.new
                              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                              @erreur.appli = "rails - FacturesController - update"
                              @erreur.origine = "erreur Save Projet - params[:projet][:id]=" + params[:projet][:id].to_s
                              @erreur.numLigne = '453'
                              @erreur.message = e.message
                              @erreur.parametreId = params[:parametre][:id].to_s
                              @erreur.save
                              @erreurUpdate = 1
                          end
                      rescue => e  # Incident Find Projet
                          @erreur = Erreur.new
                          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                          @erreur.appli = "rails - FacturesController - update"
                          @erreur.origine = "erreur Find Projet - params[:projet][:id]=" + params[:projet][:id].to_s
                          @erreur.numLigne = '446'
                          @erreur.message = e.message
                          @erreur.parametreId = params[:parametre][:id].to_s
                          @erreur.save
                          @erreurUpdate = 1
                      end
                  end
              end
          rescue => e  # Incident Update Facture
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = "rails - FacturesController - update"
              @erreur.origine = "erreur Update Facture - Facture.find(params[:id])=" + params[:id].to_s
              @erreur.numLigne = '417'
              @erreur.message = e.message
              @erreur.parametreId = params[:parametre][:id].to_s
              @erreur.save
              @erreurUpdate = 1
          end
      end
      respond_to do |format|
          if @erreurUpdate == 0
              fact = "ffactureOK" + @facture.majTache.to_s
              format.xml { render request.format.to_sym => fact }
          else
              format.xml { render request.format.to_sym => "ffacErreurU" }
          end
      end ## End respond_to
  end ## ------ END UPDATE --------




## DELETE /factures/1 ********* SUPPRESSION ****************************************************************
  # DELETE /factures/1.xml  --- Réservé à un BdC Avenant (sans aucune facture Avenant) ---
  def destroy
      @current_time = DateTime.now
      @erreurDestroy = 0
      begin
          @facture = Facture.find(params[:id])
          begin
              @facture.destroy
              begin
                  @projet = Projet.find(params[:projet][:id])
                  @projet.proCaHt = params[:projet][:proCaHt]
                  @projet.majDate = params[:projet][:majDate]
                  @proNumRangArray = @projet.proNumRang.split("|")
                  @proNumRangArray[2] = ''
                  @proNumRangArray[3] = '-1'
                  @projet.proNumRang = @proNumRangArray.join('|');
                  begin
                      @projet.save
                  rescue => e # Incident Maj du Projet
                      @erreur = Erreur.new
                      @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                      @erreur.appli = 'rails - FacturesController - destroy'
                      @erreur.origine = "erreur Save projet - @projet.id=" + @projet.id.to_s
                      @erreur.numLigne = '519'
                      @erreur.message = e.message
                      @erreur.parametreId = params[:parametre][:id].to_s
                      @erreur.save
                      @erreurDestroy = 1
                  end
              rescue => e # Incident Find Projet
                  @erreur = Erreur.new
                  @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                  @erreur.appli = 'rails - FacturesController - destroy'
                  @erreur.origine = "erreur Find Projet - Projet.find(params[:projet][:id])=" + params[:projet][:id].to_s
                  @erreur.numLigne = '511'
                  @erreur.message = e.message
                  @erreur.parametreId = params[:parametre][:id].to_s
                  @erreur.save
                  @erreurDestroy = 1
              end
          rescue => e # Incident lors de la suppression de la Facture
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = 'rails - FacturesController - destroy'
              @erreur.origine = "erreur Delete Facture - Facture.id=" + params[:id].to_s
              @erreur.numLigne = '509'
              @erreur.message = e.message
              @erreur.parametreId = params[:parametre][:id].to_s
              @erreur.save
              @erreurDestroy = 1
          end
      rescue => e # Incident Find de la Facture
          @erreur = Erreur.new
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = 'rails - FacturesController - destroy'
          @erreur.origine = "erreur Find Facture - Facture.id=" + params[:id].to_s
          @erreur.numLigne = '507'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:id].to_s
          @erreur.save
          @erreurDestroy = 1
      end
      respond_to do |format|
          if @erreurDestroy == 0
              format.xml { render request.format.to_sym => "ffactureOK" }
          else
              format.xml { render request.format.to_sym => "ffacErreurD" }
          end
      end
  end


  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def facture_params
      params.require(:facture).permit!
    end
    def parametre_params
      params.require(:parametre).permit!
    end
    def projet_params
      params.require(:projet).permit!
    end
end
