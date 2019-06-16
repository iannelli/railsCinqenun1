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
              @fatureLast = @projet.factures.last
              case @fatureLast.typeImpr.to_s
                  when '10'
                      if params[:facture][:typeImpr].to_s == '10' || params[:facture][:typeImpr].to_s == '11'
                          @erreurCreate = 2
                      end
                  when '11', '20', '40'
                      if params[:facture][:typeImpr].to_s == '10' || params[:facture][:typeImpr].to_s == '11' || params[:facture][:typeImpr].to_s == '20'
                          @erreurCreate = 2
                      end
                  when '50'
                      if params[:facture][:typeImpr].to_s == '10' || params[:facture][:typeImpr].to_s == '20' || params[:facture][:typeImpr].to_s == '50'
                          @erreurCreate = 2
                      end
                  when '60'
                      if params[:facture][:typeImpr].to_s == '10'
                          @erreurCreate = 2
                      end 
              end
          end
      rescue => e  # Incident Find Projet
          @erreur = Erreur.new
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = "rails - FacturesController - create"
          @erreur.origine = "erreur Find Projet.find(params[:projet][:id])=" + params[:projet][:id].to_s
          @erreur.numLigne = '44'
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
                          @erreur.numLigne = '89'
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
                      @erreur.numLigne = '86'
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
                                      # Si la dernière facture est une facture Solde, elle devient intermédiaire
                                      case @facture.typeImpr.to_s
                                          when '50'
                                              @fatureLast.typeImpr = '40'
                                              @fatureLast.save
                                          when '51'
                                              @fatureLast.typeImpr = '41'
                                              @fatureLast.save
                                      end
                                      begin
                                          @factAnnul.save
                                      rescue => e  # Incident Save Facture annulée
                                          @erreur = Erreur.new
                                          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                                          @erreur.appli = "rails - FacturesController - create"
                                          @erreur.origine = "erreur Save Facture annulée - params[:factannul][:id]=" + params[:factannul][:id].to_s
                                          @erreur.numLigne = '196'
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
                                      @erreur.numLigne = '183'
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
                              @erreur.numLigne = '226'
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
                      @erreur.numLigne = '165'
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
                  @erreur.numLigne = '124'
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
          @erreur.numLigne = '282'
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
              if params[:operation][:maj] == 'RImp'
                  if (tacFacElementArray[e+2].to_s == 'F' && tacFacElementArray[e+4].to_i == @facture.id)
                     tacFacElementArray[e+2] = 'I'
                  end
              end
              e += 5
          end
          begin
              @tache = Tache.find(tacFacElementArray[0].to_i)
              totalTacheHt = 0
              nbrePeriodeFacturee = 0 # Nombre de période au Statut "Facturé"
              nbrePeriodeReglee = 0 # Nombre de période au Statut "Réglé" ou "Imputé"              
              e = 0
              while (e < tacFacElementArray.length)
                  if tacFacElementArray[e+3] != "." ## montHt
                      totalTacheHt += tacFacElementArray[e+3].to_i
                  end
                  if tacFacElementArray[e+2] == "F"
                      nbrePeriodeFacturee += 1
                  end
                  if tacFacElementArray[e+2] == "R" || tacFacElementArray[e+2] == "I"
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
                  @erreur.numLigne = '368'
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
              @erreur.numLigne = '334'
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
          @erreur.numLigne = '428'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:id].to_s
          @erreur.save
          @erreurUpdate = 1
      end
      if @erreurUpdate == 0
          begin ## Mise à jour du BdC/Facture
              @facture.update(facture_params)
              
              ## Traitement spécifique d'un Règlement d'une facture ---------------------
              if params[:operation][:maj] == 'R'
                  if @facture.typeImpr.slice(0,1) != '1'
                      if @facture.typeImpr.slice(0,1) != '7'
                          @majTache = @facture.majTache.split(',')
                          e = 0
                          while (e < @majTache.length)
                              @tacFacArray.push(@majTache[e+1])
                              e += 4
                          end
                          updateTacFacString  ## MAJ Tache (Statut et tacFacString)
                      end
                      if @erreurUpdate == 0
                          if @facture.typeImpr.slice(0,1) == '7'
                              @facture.majTache = ''
                          else
                              @facture.majTache = @majTache.join(',')
                          end
                          begin
                              @facture.save
                          rescue => e  # Incident Save Facture
                              @erreur = Erreur.new
                              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                              @erreur.appli = "rails - FacturesController - update"
                              @erreur.origine = "erreur Save Facture - @facture.id=" + @facture.id.to_s
                              @erreur.numLigne = '466'
                              @erreur.message = e.message
                              @erreur.parametreId = params[:parametre][:id].to_s
                              @erreur.save
                              @erreurUpdate = 1
                          end
                      end
                  end
                  ## Traitement si Règlement Partiel de la dernière facture ('solde') - Création éventuelle d'un 'Reste en Attente'
                  if  @facture.typeImpr.slice(0,1) == '5'
                      @projet = Projet.find(params[:projet][:id])
                      @fatureLast = @projet.factures.last
                      if @fatureLast.id.to_i == @facture.id.to_i
                          if params[:projet][:proReport].to_i != 0 #Création 'Facture/Reste en Attente'
                              @factureReA = Facture.new
                              @factureReA.typeImpr = '7' + @facture.typeImpr.slice(1,1)
                              @factureReA.facStatut = '3nonRéglé'
                              @factureReA.facDateEmis = @current_time.strftime "%d/%m/%Y" # date du jour
                              @factureReA.facDelai = '0'
                              @factureReA.facDelaiMax = '0'
                              @factureReA.facDateLimite = @facture.facDateReception #date du Paiement partiel
                              temp = @current_time.strftime "%H%M%d%m%y"
                              @factureReA.facRef = 'REA' + temp
                              @factureReA.facBdC = @facture.facBdC
                              @factureReA.facRefPre = @facture.facRefPre #Ref Facture en 'Reste Du' ou 'Trop percu'
                              # facMention = montant réglé (Facture Solde) ET 'Montant Du Ttc' (Facture Solde)
                              @factureReA.facMention = @facture.facReglMont.to_s + "," + @facture.facMontTtc.to_s
                              if @paramun.parRegimeTva.to_i == 0
                                  @factureReA.facMontHt = params[:projet][:proReport].to_s
                                  @factureReA.facMontTva = '000'
                                  @factureReA.facMontTtc =  params[:projet][:proReport].to_s
                              else                             
                                  temp1 = params[:projet][:proReport].to_i / 1.2
                                  temp2 = temp1.round
                                  @factureReA.facMontHt = temp2.to_s
                                  temp1 = params[:projet][:proReport].to_i - temp2
                                  @factureReA.facMontTva = temp1.to_s
                                  @factureReA.facMontTtc =  params[:projet][:proReport].to_s # 'Reste Du' ou 'Trop percu'
                              end
                              @factureReA.facAcomMont = "000"
                              @factureReA.facTotalDu = params[:projet][:proReport].to_s
                              @factureReA.majTache = @facture.majTache
                              @factureReA.facCourrier = '0,0'
                              @factureReA.projetId = @facture.projetId
                              @factureReA.parametreId = @facture.parametreId
                              @factureReA.save
                              @erreurUpdate = 2
                          end
                      end
                  end
                  ## FIN Traitement si Règlement Partiel de la dernière facture ('solde')
                  if @erreurUpdate != 1
                      if params[:parametre][:facSituationImpositionTva].to_s == 'C1' 
                          @paramun.parRegimeTva = params[:parametre][:parRegimeTva].to_s
                          @paramun.parChoixTauxTva = params[:parametre][:parChoixTauxTva].to_s
                          @paramun.parDepass = params[:parametre][:parDepass].to_s
                          begin
                              @paramun.save
                          rescue => e  # Incident Save Projet
                              @erreur = Erreur.new
                              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                              @erreur.appli = "rails - FacturesController - update"
                              @erreur.origine = "erreur Save Paramun - @paramun.id=" + @paramun.id.to_s
                              @erreur.numLigne = '529'
                              @erreur.message = e.message
                              @erreur.parametreId = params[:parametre][:id].to_s
                              @erreur.save
                              @erreurUpdate = 1
                          end
                      end
                  end
              end
              ## FIN Traitement d'un Règlement ---------------------
              ## Traitement d'une Imputation sur le Compte du Client ---------------
              if params[:operation][:maj] == 'RImp'
                  ## Maj des Taches de la facture Imputée (seulement pour une facture Solde)
                  if @facture.typeImpr.slice(0,1) == '5'                  
                      @majTache = @facture.majTache.split(',')
                      e = 0
                      while (e < @majTache.length)
                          @tacFacArray.push(@majTache[e+1])
                          e += 4
                      end
                      updateTacFacString  ## MAJ Tache (Statut et tacFacString)
                      @facture.majTache = @majTache.join(',')
                      begin
                          @facture.save
                      rescue => e  # Incident Save Facture
                          @erreur = Erreur.new
                          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                          @erreur.appli = "rails - FacturesController - update"
                          @erreur.origine = "erreur Save Facture - @facture.id=" + @facture.id.to_s
                          @erreur.numLigne = '558'
                          @erreur.message = e.message
                          @erreur.parametreId = params[:parametre][:id].to_s
                          @erreur.save
                          @erreurUpdate = 1
                      end
                  end
                  ## Maj du Compte du Client
                  @clientele = Clientele.find(params[:projet][:clienteleFactureId])
                  @clientele.cliCompte = params[:clientele][:cliCompte].to_s
                  @clientele.save
              end
              ## FIN du Traitement d'Imputation sur le Compte du Client
              if @erreurUpdate != 1
                  if params[:operation][:maj] != 'ULet'
                      begin
                          @projet = Projet.find(params[:projet][:id])
                          @projet.proCliString = params[:projet][:proCliString]                         
                          if params[:operation][:maj] == 'R'
                              @projet.proSituation = params[:projet][:proSituation]
                              if params[:projet][:proFacHt].to_s != "neant"
                                  @projet.proSuiviFac = params[:projet][:proSuiviFac]                                  
                                  @projet.proReglMont = params[:projet][:proReglMont]
                                  @projet.proReport = params[:projet][:proReport]
                                  @projet.majDate = params[:projet][:majDate]
                              end
                          end
                          if params[:operation][:maj] == 'RImp'
                              @projet.proSuiviFac = params[:projet][:proSuiviFac]
                              @projet.proReport = params[:projet][:proReport]
                              @projet.proSituation = params[:projet][:proSituation]
                              @projet.majDate = params[:projet][:majDate]
                          end
                          begin
                              @projet.save
                          rescue => e  # Incident Save Projet
                              @erreur = Erreur.new
                              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                              @erreur.appli = "rails - FacturesController - update"
                              @erreur.origine = "erreur Save Projet - params[:projet][:id]=" + params[:projet][:id].to_s
                              @erreur.numLigne = '598'
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
                          @erreur.numLigne = '580'
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
              @erreur.numLigne = '445'
              @erreur.message = e.message
              @erreur.parametreId = params[:parametre][:id].to_s
              @erreur.save
              @erreurUpdate = 1
          end
      end
      respond_to do |format|
          case @erreurUpdate
              when 0
                  fact = "ffactureOK" + @facture.majTache.to_s
                  format.xml { render request.format.to_sym => fact }
              when 1
                  format.xml { render request.format.to_sym => "ffacErreurU" }
              when 2
                  format.xml { render xml: @factureReA }
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
                      @erreur.numLigne = '669'
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
                  @erreur.numLigne = '661'
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
              @erreur.numLigne = '659'
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
          @erreur.numLigne = '657'
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
