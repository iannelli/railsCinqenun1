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
          @erreur.appli = 'rails - ProjetoldsController - create'
          @erreur.origine = 'Incident Find Parametre - @paramun.id=' + params[:parametre][:parametreId].to_s
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
              @erreurold = Erreurold.new
              @erreurold.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreurold.appli = 'rails - ProjetoldsController - create'
              @erreurold.origine = 'Incident Find Projet - projet.id=' + params[:projetold][:id].to_s
              @erreurold.numLigne = '61'
              @erreurold.message = e.message
              @erreurold.parametreoldId = params[:parametre][:parametreId].to_s
              @erreurold.save
              @erreurArchivage = 1
              
          end
      end
      # Création du Projetold ---
      if @erreurArchivage == 0
          @projetold = Projetold.new(projetold_params)
          @projetold.parametreoldId = params[:parametre][:parametreId].to_s
          begin
              @projetold.save
              case @projetold.proSituation.to_s
                  when '20'
                      cpt = @paramun.nbreDevisInactif.to_i + 1
                      @paramun.nbreDevisInactif = cpt.to_s
                  when '21'
                      cpt = @paramun.nbreProjetInactif.to_i + 1
                      @paramun.nbreProjetInactif = cpt.to_s
                  when '22'
                      cpt = @paramun.nbreProjetClos.to_i + 1
                      @paramun.nbreProjetClos = cpt.to_s
              end
              @paramun.save
          rescue => e
              @erreurold = Erreurold.new
              @erreurold.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreurold.appli = 'rails - ProjetoldsController - create'
              @erreurold.origine = 'Incident Create Projetold'
              @erreurold.numLigne = '80'
              @erreurold.message = e.message
              @erreurold.parametreoldId = params[:parametre][:parametreId].to_s
              @erreurold.save
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
                  @tacheold.tacStringTravail = tache.tacStringTravail
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
                  @tacheold.tacFacString = tache.tacFacString
                  @tacheold.projetoldId = tache.projetId
                  @tacheold.typetacheId = tache.typetacheId
                  @tacheold.parametreoldId = tache.parametreId
                  begin
                      @tacheold.save
                  rescue => e # erreur Tacheold Create
                      @erreurold = Erreurold.new
                      @erreurold.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                      @erreurold.appli = 'rails - ProjetoldsController - create'
                      @erreurold.origine = 'Incident Create Tacheold - tache.id=' + tache.id.to_s
                      @erreurold.numLigne = '147'
                      @erreurold.message = e.message
                      @erreurold.parametreoldId = params[:parametre][:parametreId].to_s
                      @erreurold.save
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
                  @factureold.facMontHt = facture.facMontHt
                  @factureold.facMontTva = facture.facMontTva
                  @factureold.facMontTtc = facture.facMontTtc
                  @factureold.facAcomTaux = facture.facAcomTaux
                  @factureold.facAcomMont = facture.facAcomMont
                  @factureold.facImputProjet = facture.facImputProjet
                  @factureold.facImputClient = facture.facImputClient
                  @factureold.facDifference = facture.facDifference
                  @factureold.facTotalDu = facture.facTotalDu
                  @factureold.modePaieLib = facture.modePaieLib
                  @factureold.facReglMont = facture.facReglMont
                  @factureold.facStringLigne = facture.facStringLigne
                  @factureold.majTache = facture.majTache
                  @factureold.facDepass = facture.facDepass
                  @factureold.facTypeDecla = facture.facTypeDecla
                  @factureold.facCourrier = facture.facCourrier
                  @factureold.facReA = facture.facReA
                  @factureold.projetoldId = facture.projetId
                  @factureold.parametreoldId = facture.parametreId
                  begin
                      @factureold.save
                  rescue => e # erreur Factureold Create
                      @erreurold = Erreurold.new
                      @erreurold.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                      @erreurold.appli = 'rails - ProjetoldsController - create'
                      @erreurold.origine = 'Incident Create Factureold - facture.id=' + facture.id.to_s
                      @erreurold.numLigne = '197'
                      @erreurold.message = e.message
                      @erreurold.parametreoldId = params[:parametre][:parametreId].to_s
                      @erreurold.save
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
                      @erreurold = Erreurold.new
                      @erreurold.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                      @erreurold.appli = 'rails - ProjetoldsController - create'
                      @erreurold.origine = "erreur destroy Tache - tache.id =" + tache.id.to_s
                      @erreurold.numLigne = '218'
                      @erreurold.message = e.message
                      @erreurold.parametreoldId = params[:parametre][:parametreId].to_s
                      @erreurold.save
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
                      @erreurold = Erreurold.new
                      @erreurold.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                      @erreurold.appli = 'rails - ProjetoldsController - create'
                      @erreurold.origine = "erreur destroy Facture - facture.id =" + facture.id.to_s
                      @erreurold.numLigne = '238'
                      @erreurold.message = e.message
                      @erreurold.parametreoldId = params[:parametre][:parametreId].to_s
                      @erreurold.save
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
              @erreurold = Erreurold.new
              @erreurold.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreurold.appli = 'rails - ProjetoldsController - create'
              @erreurold.origine = "erreur destroy Projet - @projet.id =" + @projet.id.to_s
              @erreurold.numLigne = '256'
              @erreurold.message = e.message
              @erreurold.parametreoldId = params[:parametre][:parametreId].to_s
              @erreurold.save
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
      @erreurReactivation = 0
      # Find Parametre ----
      begin
          @paramun = Paramun.find(params[:parametre][:parametreId].to_i)
      rescue => e
          @erreurold = Erreurold.new
          @erreurold.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreurold.appli = 'rails - ProjetoldsController - update'
          @erreurold.origine = 'Incident Find Parametre.id ' + params[:parametre][:parametreId].to_s
          @erreurold.numLigne = '286'
          @erreurold.message = e.message
          @erreurold.parametreoldId = params[:parametre][:parametreId].to_s
          @erreurold.save
          @erreurReactivation = 1
      end
      # Find Projetold ---
      if @erreurReactivation == 0
          begin
              @projetold = Projetold.find(params[:id])
          rescue => e
              @erreurold = Erreurold.new
              @erreurold.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreurold.appli = 'rails - ProjetoldsController - update'
              @erreurold.origine = 'Incident Find Projetold.id ' + params[:id].to_s
              @erreurold.numLigne = '301'
              @erreurold.message = e.message
              @erreurold.parametreoldId = params[:parametre][:parametreId].to_s
              @erreurold.save
              @erreurReactivation = 1
          end
      end
      # Création Projet ----
      if @erreurReactivation == 0
          @projet = Projet.new(projetold_params)
          @projet.parametreId = params[:parametre][:parametreId].to_s
          begin
              @projet.save
              case @projet.proSituation.to_s
                  when '00'
                      cpt = @paramun.nbreDevisInactif.to_i - 1
                      @paramun.nbreDevisInactif = cpt.to_s
                  when '01'
                      cpt = @paramun.nbreProjetInactif.to_i - 1
                      @paramun.nbreProjetInactif = cpt.to_s
              end
              @paramun.save
          rescue => e # erreur Projet Create
              @erreurold = Erreurold.new
              @erreurold.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreurold.appli = 'rails - ProjetoldsController - update'
              @erreurold.origine = 'Incident Create Projet - projet.id=' + params[:id].to_s
              @erreurold.numLigne = '319'
              @erreurold.message = e.message
              @erreurold.parametreoldId = params[:parametre][:parametreId].to_s
              @erreurold.save
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
                  @tache.tacStringTravail = tacheold.tacStringTravail
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
                  @tache.tacFacString = tacheold.tacFacString
                  @tache.projetId = tacheold.projetoldId
                  @tache.typetacheId = tacheold.typetacheId
                  @tache.parametreId = tacheold.parametreoldId
                  begin
                      @tache.save
                  rescue => e # erreur Tache Create
                      @erreurold = Erreurold.new
                      @erreurold.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                      @erreurold.appli = 'rails - ProjetoldsController - update'
                      @erreurold.origine = 'Incident Create Tache - tacheold.id=' + tacheold.id.to_s
                      @erreurold.numLigne = '383'
                      @erreurold.message = e.message
                      @erreurold.parametreoldId = params[:parametre][:parametreId].to_s
                      @erreurold.save
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
                  @facture.facMontHt = factureold.facMontHt
                  @facture.facMontTva = factureold.facMontTva
                  @facture.facMontTtc = factureold.facMontTtc
                  @facture.facAcomTaux = factureold.facAcomTaux
                  @facture.facAcomMont = factureold.facAcomMont
                  @facture.facImputProjet = factureold.facImputProjet
                  @facture.facImputClient = factureold.facImputClient
                  @facture.facDifference = factureold.facDifference
                  @facture.facTotalDu = factureold.facTotalDu
                  @facture.modePaieLib = factureold.modePaieLib
                  @facture.facReglMont = factureold.facReglMont
                  @facture.facStringLigne = factureold.facStringLigne
                  @facture.majTache = factureold.majTache
                  @facture.facDepass = factureold.facDepass
                  @facture.facTypeDecla = factureold.facTypeDecla
                  @facture.facCourrier = factureold.facCourrier
                  @facture.facReA = factureold.facReA
                  @facture.projetId = factureold.projetoldId
                  @facture.parametreId = factureold.parametreoldId
                  begin
                      @facture.save
                  rescue => e # erreur Facture Create
                      @erreurold = Erreurold.new
                      @erreurold.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                      @erreurold.appli = 'rails - ProjetoldsController - update'
                      @erreurold.origine = 'Incident Create Facture - factureold.id=' + factureold.id.to_s
                      @erreurold.numLigne = '433'
                      @erreurold.message = e.message
                      @erreurold.parametreoldId = params[:parametre][:parametreId].to_s
                      @erreurold.save
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
                      @erreurold = Erreurold.new
                      @erreurold.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                      @erreurold.appli = 'rails - ProjetoldsController - update'
                      @erreurold.origine = "erreur destroy Tacheold - tacheold.id =" + tacheold.id.to_s
                      @erreurold.numLigne = '454'
                      @erreurold.message = e.message
                      @erreurold.parametreoldId = params[:parametre][:parametreId].to_s
                      @erreurold.save
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
                      @erreurold = Erreurold.new
                      @erreurold.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                      @erreurold.appli = 'rails - ProjetoldsController - update'
                      @erreurold.origine = "erreur destroy Factureold - factureold.id =" + factureold.id.to_s
                      @erreurold.numLigne = '474'
                      @erreurold.message = e.message
                      @erreurold.parametreoldId = params[:parametre][:parametreId].to_s
                      @erreurold.save
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
              @erreurold = Erreurold.new
              @erreurold.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreurold.appli = 'rails - ProjetoldsController - update'
              @erreurold.origine = "erreur destroy Projetold - @projetold.id =" + @projetold.id.to_s
              @erreurold.numLigne = '492'
              @erreurold.message = e.message
              @erreurold.parametreoldId = params[:parametre][:parametreId].to_s
              @erreurold.save
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
