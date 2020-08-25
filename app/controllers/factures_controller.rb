class FacturesController < ApplicationController

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
      @origine = 'C'
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
                  when '11', '40'
                      if params[:facture][:typeImpr].to_s == '10' || params[:facture][:typeImpr].to_s == '11'
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

      ##  Application des Modifications des Tache.tacPeriode générées (éventuellement) lors de la Création de la Facture par Cinqenun[TWTachesFacture.mxml] ------
      if params[:tache][:paramMajTacPeriode] != 'neant'
          @paramMajTacPeriodeArray = params[:tache][:paramMajTacPeriode].split('|')
          update_tache_tacperiode_trait
      end

      ## Création de la Facture ------------------------
      if @erreurCreate == 0
          @proNumRangArray = @projet.proNumRang.split("|")
          @facture = Facture.new(facture_params)
          @facture.projetId = @projet.id.to_i
          begin
              @facture.save
              # Maj de proNumRang du Projet correspondant ------
              maj_numrang_projet_trait
              @projet.proNumRang = @proNumRangArray.join('|')
              @projet.proCliString = params[:projet][:proCliString]
              @projet.proSuiviFac = params[:projet][:proSuiviFac]
              if params[:projet][:proCaHt].to_s != "neant" # Maj des données financières du Projet
                  @projet.proCaHt = params[:projet][:proCaHt]
                  @projet.proFacHt = params[:projet][:proFacHt]
                  @projet.proMarge = params[:projet][:proMarge]
                  @projet.proReglMont = params[:projet][:proReglMont]
                  @projet.proReportFacture = params[:projet][:proReportFacture]
                  @projet.proReportDebours = params[:projet][:proReportDebours]
                  @projet.majDate = params[:projet][:majDate]
              end
              begin
                  @projet.save
                  ## Autres MAJ -----
                  case @facture.typeImpr.to_s
                      when '40', '50', '41', '51' ##-- Facture Intermédiaire et Solde ---
                          update_parametre_numfact_trait ## MAJ Identité (Numéro de Facture)
                          if @erreurCreate == 0
                              update_facture_tacperiode_trait #Maj des Taches facturées (tacPeriode et tacStatut)
                          end
                      when '60', '61' ##-- Facture Avoir  ---
                          update_parametre_numfact_trait ## MAJ Identité (Numéro de Facture)
                          if @erreurCreate == 0
                              begin
                                  @factAnnul = Facture.find(params[:factannul][:id])
                                  ## MAJ Tache (Statut et tacPeriode)
                                  if @factAnnul.typeImpr.to_s != '20'
                                      update_facture_tacperiode_trait # Ne concerne pas l'Annulation d'une Facture d'Acompte
                                  end                             
                                  ## MAJ du Statut de la facture Annulée si créationFacture Avoir ******
                                  @factAnnul.facStatut = "3Annulé"
                                  @factAnnul.facMention = "**** Facture Annulée ****"
                                  @factAnnul.facDepass = '0'
                                  @factAnnul.facReA = ''
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

      ## Maj Compte Client -----------------------------------------
      if @erreurCreate == 0
          if params[:clientele][:id].to_s != "neant"
              begin
                  @clientele = Clientele.find(params[:clientele][:id].to_i)
                  @clientele.cliCompte = params[:clientele][:cliCompte].to_s
                  @clientele.save
              rescue => e  # Incident Find Save Clientele
                  @erreur = Erreur.new
                  @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                  @erreur.appli = "rails - FacturesController - create"
                  @erreur.origine = "erreur Find/Maj Clientele.cliCompte"
                  @erreur.numLigne = '265'
                  @erreur.message = e.message
                  @erreur.parametreId = params[:parametre][:id].to_s
                  @erreur.save
                  @erreurCreate = 1
              end
          end
      end
      # Traitement Final de la Création -----
      respond_to do |format|
          case @erreurCreate
            when 0
                format.xml { render xml: @facture }
            when 1
                format.xml { render request.format.to_sym => "ffacErreurC1" }
            when 2
                format.xml { render request.format.to_sym => "ffacErreurC2" }
            when 3
                format.xml { render request.format.to_sym => "ffacErreurC3" }
          end
      end # End Respond Format -----
  end
## ------ END CREATE -------------


## PUT /factures/1 ********* MISE A JOUR FACTURE **********************************************************************
  # PUT /factures/1.xml
  def update
      @current_time = DateTime.now
      @origine = 'U'
      @erreurUpdate = 0
      begin
          @facture = Facture.find(params[:id])
          @tacFacArray  = []
      rescue => e  # Incident Find BdC/Facture
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

      if @erreurUpdate == 0 ## Mise à jour du BdC/Facture
          begin 
              @facture.update(facture_params)
          rescue => e  # Incident Update Bdc/Facture
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = "rails - FacturesController - update"
              @erreur.origine = "erreur Update Facture - Facture.find(params[:id])=" + params[:id].to_s
              @erreur.numLigne = '467'
              @erreur.message = e.message
              @erreur.parametreId = params[:parametre][:id].to_s
              @erreur.save
              @erreurUpdate = 1
          end
      end

      if @erreurUpdate == 0 ## Règlement d'un Bon de Commande ou d'une Facture : Traitement spécifique ----
          if params[:operation][:maj] == 'R'
              case @facture.typeImpr.slice(0,1)
                  when '1' #Règlement d'un Bon de Commande : Création de la facture d'Acompte -----
                      if params[:acompte][:facAcompteString].to_s != 'neant'
                          @factureAcompteArray = params[:acompte][:facAcompteString].split('|')
                          if @factureAcompteArray[0].to_s == '99' 
                              update_facture_acompte_trait() # Maj Facture d'Acompte(ModeRèglement)
                          else
                              create_facture_acompte_trait() # Création Facture d'Acompte
                          end 
                      end
                  when '4', '5' #Règlement de la Facture Intermédiaire et Solde : Maj des Taches facturées ---
                      update_facture_tacperiode_trait #Maj des Taches Réglées (tacPeriode et tacStatut)
              end
          end
          ## Ré-Initialisation du BdC : Création Facture d'Avoir, Maj Facture Acompte Annulé et Maj Projet
          if params[:operation][:maj] == 'Rinit'
              annul_facture_acompte_trait
          end
      end ## FIN Traitement d'un Règlement d'une Facture ---------------------

      if @erreurUpdate == 0  ## Save uniquement Facture ---------------
          begin
              @facture.save
          rescue => e  # Incident Save Facture
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = "rails - FacturesController - update"
              @erreur.origine = "erreur Save Facture - @facture.id=" + @facture.id.to_s
              @erreur.numLigne = '501'
              @erreur.message = e.message
              @erreur.parametreId = params[:parametre][:id].to_s
              @erreur.save
              @erreurUpdate = 1
          end
      end

      if @erreurUpdate == 0  ## Traitement du Règlement d'un "Reste en Attente" : MAJ CLIENTELE ---------------
          if params[:operation][:maj] == 'Rrea'
              if params[:clientele][:id].to_s != 'neant'
                  begin
                      @clientele = Clientele.find(params[:clientele][:id])
                      @clientele.cliCompte = params[:clientele][:cliCompte].to_s
                      @clientele.save
                  rescue => e  # Incident Save Clientele
                      @erreur = Erreur.new
                      @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                      @erreur.appli = "rails - FacturesController - update"
                      @erreur.origine = "erreur Find/Save Clientele - @clientele.id=" + @clientele.id.to_s
                      @erreur.numLigne = '520'
                      @erreur.message = e.message
                      @erreur.parametreId = params[:parametre][:id].to_s
                      @erreur.save
                      @erreurUpdate = 1
                  end
              end
          end
      end

      if @erreurUpdate == 0 ## Traitement de Paramun
          if params[:operation][:maj] != 'ULet'
              if params[:parametre][:facSituationImpositionTva].to_s == 'C1'
                  @paramun.parStatutRegime = params[:parametre][:parStatutRegime].to_s
                  @paramun.parChoixTauxTva = params[:parametre][:parChoixTauxTva].to_s
                  @paramun.parDepass = params[:parametre][:parDepass].to_s
                  begin
                      @paramun.save
                  rescue => e  # Incident Save Paramun
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

      if @erreurUpdate == 0 ## Traitement d'une Imputation sur le Compte du Client ---------------
          if params[:operation][:maj] == 'RRep'
              ## Maj des Taches de la facture Reportée (facture Intermédiaire et Solde)
              if @facture.typeImpr.slice(0,1) == '4' || @facture.typeImpr.slice(0,1) == '5'
                  update_facture_tacperiode_trait #Maj des Taches (tacPeriode et tacStatut)
              end
              ## Maj du Compte du Client
              @clientele = Clientele.find(params[:projet][:clienteleFactureId])
              @clientele.cliCompte = params[:clientele][:cliCompte].to_s
              @clientele.save
          end
      end

      if @erreurUpdate == 0 || @erreurUpdate == 4  ## Maj Projet ----------------------
          if params[:operation][:maj] != 'ULet'
              begin
                  @projet = Projet.find(params[:projet][:id])
                  if params[:operation][:maj] == 'R'
                      @projet.proCliString = params[:projet][:proCliString]
                      @projet.proSituation = params[:projet][:proSituation]
                      @projet.majDate = params[:projet][:majDate]
                      if params[:operation][:proMajFactureResult] == '1'
                          @projet.proSuiviFac = params[:projet][:proSuiviFac]
                          @projet.proReglMont = params[:projet][:proReglMont]
                          @projet.proReportFacture = params[:projet][:proReportFacture]
                      @projet.proReportDebours = params[:projet][:proReportDebours]
                      end
                  end
                  if params[:operation][:maj] == 'RRep'
                      @projet.proCliString = params[:projet][:proCliString]
                      @projet.proSuiviFac = params[:projet][:proSuiviFac]
                      @projet.proReportFacture = params[:projet][:proReportFacture]
                      @projet.proReportDebours = params[:projet][:proReportDebours]
                      @projet.proSituation = params[:projet][:proSituation]
                      @projet.majDate = params[:projet][:majDate]
                  end
                  if params[:operation][:maj] == 'Rrea'
                      @projet.proReportFacture = params[:projet][:proReportFacture]
                      @projet.proReportDebours = params[:projet][:proReportDebours]
                      @projet.majDate = params[:projet][:majDate]
                  end
                  begin
                      @projet.save
                  rescue => e  # Incident Save Projet
                      @erreur = Erreur.new
                      @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                      @erreur.appli = "rails - FacturesController - update"
                      @erreur.origine = "erreur Save Projet - params[:projet][:id]=" + params[:projet][:id].to_s
                      @erreur.numLigne = '617'
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
                  @erreur.numLigne = '595'
                  @erreur.message = e.message
                  @erreur.parametreId = params[:parametre][:id].to_s
                  @erreur.save
                  @erreurUpdate = 1
              end
          end
      end

      respond_to do |format| ## Traitement Final ---------------------------
          case @erreurUpdate
              when 0
                  format.xml { render request.format.to_sym => "ffactureOK" }
              when 1
                  format.xml { render request.format.to_sym => "ffacErreurU1" }
              when 2
                  format.xml { render request.format.to_sym => "ffacErreurU2" }
              when 3
                  format.xml { render request.format.to_sym => "ffacErreurU2" }
              when 4
                  format.xml { render xml: @factureAcompte }
              when 5
                  format.xml { render xml: @factureAvoir }
          end
      end ## End respond_to
  end ## ------ END UPDATE ----------------------------------




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
