class ProjetoldsController < ApplicationController

  # GET /projetolds ****** CHARGEMENT ************************
  def index
      #@projetolds = Projetold.all
      @IndexOK = 0
      # Find Paramunold ---
      begin
          @paramunold = Paramunold.find(params[:parametre][:id].to_i)
       rescue => e
          @erreur = Erreur.new
          @current_time = DateTime.now
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = 'rails - ProjetoldsController - index'
          @erreur.origine = 'Incident Find Parametreold - @paramunold.id=' + params[:parametre][:id].to_s
          @erreur.numLigne = '9'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:id].to_s
          @erreur.save
          @IndexOK = 1
      end
      if @IndexOK == 0
          @projetolds = @paramunold.projetolds
      end
      respond_to do |format|
          if @IndexOK == 1
              format.xml { render request.format.to_sym => "oprErreurI" }  # Incident Find Parametreold
          else
              if @projetolds.empty?
                 format.xml { render request.format.to_sym => "oprErreurA" }  # Aucun Projetold sélectionné
              else
                 format.xml { render xml: @projetolds }
              end
          end
      end
  end


  # POST /projetolds ********* CREATE ***************************************
  # Archivage : Création d'un Projetold et suppression du Projet correspondant
  def create
      @current_time = DateTime.now
      @erreurArchivage = 0
      # Find Parametre ---
      begin
          @paramun = Paramun.find(params[:parametre][:parametreId].to_i)
       rescue => e
          @erreur = Erreur.new
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = '1'
          @erreur.origine = 'ProjetoldsController[create]: Incident Find Parametre - @paramun.id=' + params[:parametre][:parametreId].to_s
          @erreur.numLigne = '46'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:parametreId].to_s
          @erreur.save
          @erreurArchivage = 1
      end
      # Find Projet ---
       if @erreurArchivage == 0
          begin
              @projet = Projet.find(params[:projetold][:id].to_i)
          rescue => e
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = '1'
              @erreur.origine = 'ProjetoldsController[create]: Incident Find Projet - projet.id=' + params[:projetold][:id].to_s
              @erreur.numLigne = '61'
              @erreur.message = e.message
              @erreur.parametreoldId = params[:parametre][:parametreId].to_s
              @erreur.save
              @erreurArchivage = 1
              
          end
      end
      # Création du Projetold ---
      if @erreurArchivage == 0
          @projetold = Projetold.new(projetold_params)
          @projetold.parametreoldId = params[:parametre][:parametreId].to_s
          begin
              @projetold.save
          rescue => e
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = '1'
              @erreur.origine = 'ProjetoldsController[create]: Incident Create Projetold'
              @erreur.numLigne = '80'
              @erreur.message = e.message
              @erreur.parametreoldId = params[:parametre][:parametreId].to_s
              @erreur.save
              @erreurArchivage = 1
          end
      end
      # Création des Tacheold du Projetold ---
      if @erreurArchivage == 0 
          if @projet.taches.length != 0
              @projet.taches.each do |tache|
                  @tacheold = Tacheold.new
                  @tacheold.id = tache.id
                  @tacheold.famtacNum = tache.famtacNum
                  @tacheold.typetacLib = tache.typetacLib
                  @tacheold.tacCategorie = tache.tacCategorie
                  @tacheold.tacLibCourt = tache.tacLibCourt
                  @tacheold.tacLibPeriode = tache.tacLibPeriode
                  @tacheold.tacLibDetail = tache.tacLibDetail
                  @tacheold.typetacNat = tache.typetacNat
                  @tacheold.tacModeFac = tache.tacModeFac
                  @tacheold.tacProLib = tache.tacProLib
                  @tacheold.tacStatut = tache.tacStatut
                  @tacheold.tacCoutHeure = tache.tacCoutHeure
                  @tacheold.tacDateDeb = tache.tacDateDeb
                  @tacheold.tacDeadLine = tache.tacDeadLine
                  @tacheold.tacAchevement = tache.tacAchevement
                  @tacheold.tacTravail = tache.tacTravail
                  @tacheold.typetacUnite = tache.typetacUnite
                  @tacheold.typetacTarifUnite = tache.typetacTarifUnite
                  @tacheold.typetacET = tache.typetacET
                  @tacheold.tacQuantUnitaire = tache.tacQuantUnitaire
                  @tacheold.tacPeriodeNbre = tache.tacPeriodeNbre
                  @tacheold.tacQuantTotal = tache.tacQuantTotal
                  @tacheold.tacMont = tache.tacMont
                  @tacheold.tacRemiseTaux = tache.tacRemiseTaux
                  @tacheold.tacBdcHt = tache.tacBdcHt
                  @tacheold.tacDureeBdc = tache.tacDureeBdc
                  @tacheold.tacFacHt = tache.tacFacHt
                  @tacheold.tacDureeExec = tache.tacDureeExec
                  @tacheold.tacPourExec = tache.tacPourExec
                  @tacheold.tacCout = tache.tacCout
                  @tacheold.tacMarge = tache.tacMarge
                  @tacheold.tacPeriode = tache.tacPeriode
                  @tacheold.projetoldId = tache.projetId
                  @tacheold.typetacheId = tache.typetacheId
                  @tacheold.parametreoldId = tache.parametreId
                  begin
                      @tacheold.save
                  rescue => e # erreur Tacheold Create
                      @erreur = Erreur.new
                      @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                      @erreur.appli = '1'
                      @erreur.origine = 'ProjetoldsController[create]: Incident Create Tacheold - tache.id=' + tache.id.to_s
                      @erreur.numLigne = '134'
                      @erreur.message = e.message
                      @erreur.parametreoldId = params[:parametre][:parametreId].to_s
                      @erreur.save
                      @erreurArchivage = 1
                      break
                  end
              end
          end
      end
      # Création des Factureold du Projetold ---
      if @erreurArchivage == 0
          if @projet.factures.length != 0
              @projet.factures.each do |facture|
                  @factureold = Factureold.new
                  @factureold.id = facture.id
                  @factureold.typeImpr = facture.typeImpr
                  @factureold.facStatut = facture.facStatut
                  @factureold.facDateEmis = facture.facDateEmis
                  @factureold.facDelai = facture.facDelai
                  @factureold.facDelaiMax = facture.facDelaiMax
                  @factureold.facDateLimite = facture.facDateLimite
                  @factureold.facDateReception = facture.facDateReception
                  @factureold.facRef = facture.facRef
                  @factureold.facBdC = facture.facBdC
                  @factureold.facRefPre = facture.facRefPre
                  @factureold.facProCom = facture.facProCom
                  @factureold.facBdcSigne = facture.facBdcSigne
                  @factureold.facMention = facture.facMention
                  @factureold.facMontBrutHt = facture.facMontBrutHt
                  @factureold.facImputProjet = facture.facImputProjet
                  @factureold.facImputClient = facture.facImputClient
                  @factureold.facMontNetHt = facture.facMontNetHt
                  @factureold.facAcomTaux = facture.facAcomTaux
                  @factureold.facAcomMont = facture.facAcomMont
                  @factureold.facMontTva = facture.facMontTva
                  @factureold.facTypeTvaImpot = facture.facTypeTvaImpot
                  @factureold.facDeboursTtc = facture.facDeboursTtc
                  @factureold.facDeboursTva = facture.facDeboursTva
                  @factureold.facDeboursImput = facture.facDeboursImput
                  @factureold.facTotalDu = facture.facTotalDu
                  @factureold.facReglMont = facture.facReglMont
                  @factureold.modePaieLib = facture.modePaieLib
                  @factureold.facDifference = facture.facDifference
                  @factureold.facLignes = facture.facLignes
                  @factureold.facDepass = facture.facDepass
                  @factureold.facCourrier = facture.facCourrier
                  @factureold.facReA = facture.facReA
                  @factureold.projetoldId = facture.projetId
                  @factureold.parametreoldId = facture.parametreId
                  begin
                      @factureold.save
                  rescue => e # erreur Factureold Create
                      @erreur = Erreur.new
                      @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                      @erreur.appli = '1'
                      @erreur.origine = 'ProjetoldsController[create]: Incident Create Factureold - facture.id=' + facture.id.to_s
                      @erreur.numLigne = '191'
                      @erreur.message = e.message
                      @erreur.parametreoldId = params[:parametre][:parametreId].to_s
                      @erreur.save
                      @erreurArchivage = 1
                      break
                  end
              end
          end
      end
      # Suppression des Tache du Projet ---
      if @erreurArchivage == 0
          if @projet.taches.length != 0
              @projet.taches.each do |tache|
                   begin
                      tache.destroy
                  rescue => e  # Incident destroy Tache
                      @erreur = Erreur.new
                      @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                      @erreur.appli = '1'
                      @erreur.origine = "ProjetoldsController[create]: erreur destroy Tache - tache.id =" + tache.id.to_s
                      @erreur.numLigne = '212'
                      @erreur.message = e.message
                      @erreur.parametreoldId = params[:parametre][:parametreId].to_s
                      @erreur.save
                      @erreurArchivage = 1
                  end
              end
          end
      end
      # Suppression des Facture du Projet ---
      if @erreurArchivage == 0
          if @projet.factures.length != 0
              @projet.factures.each do |facture|
                  begin
                      facture.destroy
                  rescue => e  # Incident destroy Facture
                      @erreur = Erreur.new
                      @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                      @erreur.appli = '1'
                      @erreur.origine = "ProjetoldsController[create]: erreur destroy Facture - facture.id =" + facture.id.to_s
                      @erreur.numLigne = '232'
                      @erreur.message = e.message
                      @erreur.parametreoldId = params[:parametre][:parametreId].to_s
                      @erreur.save
                      @erreurArchivage = 1
                  end
              end
          end
      end
      # Suppression du Projet ---
      if @erreurArchivage == 0
          begin
              @projet.destroy
          rescue => e  # Incident destroy Projet
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = '1'
              @erreur.origine = "ProjetoldsController[create]: erreur destroy Projet - @projet.id =" + @projet.id.to_s
              @erreur.numLigne = '250'
              @erreur.message = e.message
              @erreur.parametreoldId = params[:parametre][:parametreId].to_s
              @erreur.save
              @erreurArchivage = 1
          end
      end
      # Retour ----
      respond_to do |format|
          if @erreurArchivage == 0
              format.xml { render xml: @projetold }
          else
              format.xml { render request.format.to_sym => "oprErreurC" }
          end
      end
  end




  # PATCH/PUT /projetolds/1 -- Ré-activation d'un Projet à partir du Projetold
  # Ré-activation : Création d'un Projet et suppression du Projetold correspondant
  def update
      @current_time = DateTime.now
      @erreurReactivation = 0
      # Find Parametre ----
      begin
          @paramun = Paramun.find(params[:parametre][:parametreId].to_i)
      rescue => e
          @erreur = Erreur.new
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = '1'
          @erreur.origine = 'ProjetoldsController[update]: Incident Find Parametre.id ' + params[:parametre][:parametreId].to_s
          @erreur.numLigne = '283'
          @erreur.message = e.message
          @erreur.parametreoldId = params[:parametre][:parametreId].to_s
          @erreur.save
          @erreurReactivation = 1
      end
      # Find Projetold ---
      if @erreurReactivation == 0
          begin
              @projetold = Projetold.find(params[:id])
          rescue => e
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = '1'
              @erreur.origine = 'ProjetoldsController[update]: Incident Find Projetold.id ' + params[:id].to_s
              @erreur.numLigne = '298'
              @erreur.message = e.message
              @erreur.parametreoldId = params[:parametre][:parametreId].to_s
              @erreur.save
              @erreurReactivation = 1
          end
      end
      # Création Projet ----
      if @erreurReactivation == 0
          @projet = Projet.new(projetold_params)
          @projet.majDate = @current_time.strftime "%d/%m/%Y"
          @projet.parametreId = params[:parametre][:parametreId].to_s
          begin
              @projet.save
          rescue => e # erreur Projet Create
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = '1'
              @erreur.origine = 'ProjetoldsController[update]: Incident Create Projet - projet.id=' + params[:id].to_s
              @erreur.numLigne = '317'
              @erreur.message = e.message
              @erreur.parametreoldId = params[:parametre][:parametreId].to_s
              @erreur.save
              @erreurReactivation = 1
          end
      end
      # Création Tache du Projet ---
      if @erreurReactivation == 0
          if @projetold.tacheolds.length != 0
              @projetold.tacheolds.each do |tacheold|
                  @tache = Tache.new
                  @tache.id = tacheold.id
                  @tache.famtacNum = tacheold.famtacNum
                  @tache.typetacLib = tacheold.typetacLib
                  @tache.tacCategorie = tacheold.tacCategorie
                  @tache.tacLibCourt = tacheold.tacLibCourt
                  @tache.tacLibPeriode = tacheold.tacLibPeriode
                  @tache.tacLibDetail = tacheold.tacLibDetail
                  @tache.typetacNat = tacheold.typetacNat
                  @tache.tacModeFac = tacheold.tacModeFac
                  @tache.tacProLib = tacheold.tacProLib
                  @tache.tacStatut = tacheold.tacStatut
                  @tache.tacCoutHeure = tacheold.tacCoutHeure
                  @tache.tacDateDeb = tacheold.tacDateDeb
                  @tache.tacDeadLine = tacheold.tacDeadLine
                  @tache.tacAchevement = tacheold.tacAchevement
                  @tache.tacTravail = tacheold.tacTravail
                  @tache.typetacUnite = tacheold.typetacUnite
                  @tache.typetacTarifUnite = tacheold.typetacTarifUnite
                  @tache.typetacET = tacheold.typetacET
                  @tache.tacQuantUnitaire = tacheold.tacQuantUnitaire
                  @tache.tacPeriodeNbre = tacheold.tacPeriodeNbre
                  @tache.tacQuantTotal = tacheold.tacQuantTotal
                  @tache.tacMont = tacheold.tacMont
                  @tache.tacRemiseTaux = tacheold.tacRemiseTaux
                  @tache.tacBdcHt = tacheold.tacBdcHt
                  @tache.tacDureeBdc = tacheold.tacDureeBdc
                  @tache.tacFacHt = tacheold.tacFacHt
                  @tache.tacDureeExec = tacheold.tacDureeExec
                  @tache.tacPourExec = tacheold.tacPourExec
                  @tache.tacCout = tacheold.tacCout
                  @tache.tacMarge = tacheold.tacMarge
                  @tache.tacPeriode = tacheold.tacPeriode
                  @tache.projetId = tacheold.projetoldId
                  @tache.typetacheId = tacheold.typetacheId
                  @tache.parametreId = tacheold.parametreoldId
                  begin
                      @tache.save
                  rescue => e # erreur Tache Create
                      @erreur = Erreur.new
                      @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                      @erreur.appli = '1'
                      @erreur.origine = 'ProjetoldsController[update]: Incident Create Tache - tacheold.id=' + tacheold.id.to_s
                      @erreur.numLigne = '371'
                      @erreur.message = e.message
                      @erreur.parametreoldId = params[:parametre][:parametreId].to_s
                      @erreur.save
                      @erreurReactivation = 1
                      break
                  end
              end
          end
      end
      # Création des Facture du Projet ---
      if @erreurReactivation == 0
          if @projetold.factureolds.length != 0
              @projetold.factureolds.each do |factureold|
                  @facture = Facture.new
                  @facture.id = factureold.id
                  @facture.typeImpr = factureold.typeImpr
                  @facture.facStatut = factureold.facStatut
                  @facture.facDateEmis = factureold.facDateEmis
                  @facture.facDelai = factureold.facDelai
                  @facture.facDelaiMax = factureold.facDelaiMax
                  @facture.facDateLimite = factureold.facDateLimite
                  @facture.facDateReception = factureold.facDateReception
                  @facture.facRef = factureold.facRef
                  @facture.facBdC = factureold.facBdC
                  @facture.facRefPre = factureold.facRefPre
                  @facture.facProCom = factureold.facProCom
                  @facture.facBdcSigne = factureold.facBdcSigne
                  @facture.facMention = factureold.facMention
                  @facture.facMontBrutHt = factureold.facMontBrutHt
                  @facture.facImputProjet = factureold.facImputProjet
                  @facture.facImputClient = factureold.facImputClient
                  @facture.facMontNetHt = factureold.facMontNetHt
                  @facture.facAcomTaux = factureold.facAcomTaux
                  @facture.facAcomMont = factureold.facAcomMont                  
                  @facture.facMontTva = factureold.facMontTva
                  @facture.facTypeTvaImpot = factureold.facTypeTvaImpot
                  @facture.facDeboursTtc = factureold.facDeboursTtc
                  @facture.facDeboursTva = factureold.facDeboursTva
                  @facture.facTotalDu = factureold.facTotalDu
                  @facture.facReglMont = factureold.facReglMont
                  @facture.modePaieLib = factureold.modePaieLib
                  @facture.facDifference = factureold.facDifference
                  @facture.facLignes = factureold.facLignes
                  @facture.facDepass = factureold.facDepass
                  @facture.facCourrier = factureold.facCourrier
                  @facture.facReA = factureold.facReA
                  @facture.projetId = factureold.projetoldId
                  @facture.parametreId = factureold.parametreoldId
                  begin
                      @facture.save
                  rescue => e # erreur Facture Create
                      @erreur = Erreur.new
                      @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                      @erreur.appli = '1'
                      @erreur.origine = 'ProjetoldsController[update]: Incident Create Facture - factureold.id=' + factureold.id.to_s
                      @erreur.numLigne = '427'
                      @erreur.message = e.message
                      @erreur.parametreoldId = params[:parametre][:parametreId].to_s
                      @erreur.save
                      @erreurReactivation = 1
                      break
                  end
              end
          end
      end
      # Suppression des Tacheold du Projetold ---
      if @erreurReactivation == 0
          if @projetold.tacheolds.length != 0
              @projetold.tacheolds.each do |tacheold|
                   begin
                      tacheold.destroy
                  rescue => e  # Incident destroy Tacheold
                      @erreur = Erreur.new
                      @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                      @erreur.appli = '1'
                      @erreur.origine = "ProjetoldsController[update]: erreur destroy Tacheold - tacheold.id =" + tacheold.id.to_s
                      @erreur.numLigne = '448'
                      @erreur.message = e.message
                      @erreur.parametreoldId = params[:parametre][:parametreId].to_s
                      @erreur.save
                      @erreurReactivation = 1
                  end
              end
          end
      end
      # Suppression des Factureold du Projetold ---
      if @erreurReactivation == 0
          if @projetold.factureolds.length != 0
              @projetold.factureolds.each do |factureold|
                  begin
                      factureold.destroy
                  rescue => e  # Incident destroy Factureold
                      @erreur = Erreur.new
                      @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                      @erreur.appli = '1'
                      @erreur.origine = "ProjetoldsController[update]: erreur destroy Factureold - factureold.id =" + factureold.id.to_s
                      @erreur.numLigne = '468'
                      @erreur.message = e.message
                      @erreur.parametreoldId = params[:parametre][:parametreId].to_s
                      @erreur.save
                      @erreurReactivation = 1
                  end
              end
          end
      end
      # Suppression du Projetold ---
      if @erreurReactivation == 0
          begin
              @projetold.destroy
          rescue => e  # Incident destroy Projetold
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = '1'
              @erreur.origine = "ProjetoldsController[update]: erreur destroy Projetold - @projetold.id =" + @projetold.id.to_s
              @erreur.numLigne = '486'
              @erreur.message = e.message
              @erreur.parametreoldId = params[:parametre][:parametreId].to_s
              @erreur.save
              @erreurReactivation = 1
          end
      end
      # Retour ----
      respond_to do |format|
          if @erreurReactivation == 0
              format.xml { render xml: @projet }
          else
              format.xml { render request.format.to_sym => "oprErreurU" }
          end
      end
  end


  # DELETE /projetolds/1
  def destroy
    @projetold.destroy
    redirect_to projetolds_url, notice: 'Projetold was successfully destroyed.'
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def projetold_params
      params.require(:projetold).permit!
    end
end
