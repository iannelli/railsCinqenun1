class ParamunsController < ApplicationController
  # TEST de Connexion *******************
  before_action :authenticate_rights, :except => [:index, :create, :destroy]

  def authenticate_rights
      dateConnex = params[:parametre][:parDateConnex]
      @paramun = Paramun.find(params[:parametre][:id].to_i)

      if dateConnex.to_i > @paramun.parDateConnex.to_i
          respond_to do |format|
              format.xml { render request.format.to_sym => "pparErreurS" }
          end
      end
  end


  # GET /parametres ****** CHARGEMENT ************************
  def index
      #@paramuns = Paramun.all
      @indexOK = 0
      @current_time = DateTime.now
      begin
          @paramun = Paramun.find(params[:parametre][:id])
          @paramun.parDateConnex = (@current_time.strftime "%Y%m%d%H%M%S").to_s #Date-Heure Connexion 'aaaammjjhhmnss'
          @paramun.save
      rescue => e # Incident Find de Paramun
          @erreur = Erreur.new
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = "rails - ParamunsController - index"
          @erreur.origine = "erreur Find Paramun - params[:parametre][:id]=" + params[:parametre][:id].to_s
          @erreur.numLigne = '23'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:id].to_s
          @erreur.save
          @indexOK = 1
      end

      respond_to do |format|
          case @indexOK
              when 0
                  format.xml  { render xml: @paramun }
              when 1
                  format.xml { render request.format.to_sym => "pparErreurI" } # Incident Find Paramun
          end
      end
  end


  # POST /@paramuns
  # POST /@paramuns.json
  def create
      @paramun = Paramun.new(paramun_params)
      #Application.application.Parametre.parAnFact = Application.application.dateTimeServeur.slice(6,10);
      #  Application.application.Abonne.aboNumFact = '00000';
      respond_to do |format|
          if @paramun.save
            format.html { redirect_to @paramun, notice: 'Parametre was successfully created.' }
            format.json { render :show, status: :created, location: @paramun }
          else
            format.html { render :new }
            format.json { render json: @paramun.errors, status: :unprocessable_entity }
          end
      end
  end


  # PATCH/PUT /paramuns/1
  # PATCH/PUT /paramuns/1.json
  def update
      @updateOK = 0
      @current_time = DateTime.now
      if params[:typeMaj][:maj].to_s == 'UParAbo'
          if params[:typeMaj][:par].to_s == '1'
              begin
                  @paramun.update(paramun_params)
                  @updateOK += 10 # @updateOK = 10
              rescue => e # Incident Save Paramun
                  @erreur = Erreur.new
                  @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                  @erreur.appli = "rails - ParamunsController - update"
                  @erreur.origine = "erreur update Paramun - @paramun.id=" + params[:id].to_s
                  @erreur.numLigne = '75'
                  @erreur.message = e.message
                  @erreur.parametreId = params[:id].to_s
                  @erreur.save
                  @updateOK = 2 # @updateOK = 2
              end
          end
          if @updateOK != 2
              if params[:typeMaj][:abo].to_s == '1'
                  @abonne = Abonne.find(params[:id])
                  @abonne.aboIden = params[:abonne][:aboIden].to_s
                  begin
                      @abonne.save
                      @updateOK += 10 # @updateOK = 10 ou 20
                  rescue => e # Incident Save Paramun
                      @erreur = Erreur.new
                      @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                      @erreur.appli = "rails - ParamunsController - update"
                      @erreur.origine = "erreur update Abonne - @abonne.id=" + params[:id].to_s
                      @erreur.numLigne = '94'
                      @erreur.message = e.message
                      @erreur.parametreId = params[:id].to_s.to_s
                      @erreur.save
                      @updateOK = 3
                  end
              end
          end
          respond_to do |format|
              case @updateOK
                  when 2
                      format.xml { render request.format.to_sym => "pparErreurU2" }
                  when 3
                      format.xml { render request.format.to_sym => "pparErreurU3" }
                  when 10
                      format.xml { render request.format.to_sym => "pparametreOK10" }
                  when 20
                      format.xml { render request.format.to_sym => "pparametreOK20" }
              end
          end
      end
      # Mise à jour des Données fiscales suite au Dépassement du Seuil Franchise
      if params[:typeMaj][:maj].to_s == 'UParDep'
          begin
              @paramun.update(paramun_params)
          rescue => e # Incident Save Paramun
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = "rails - ParamunsController - update"
              @erreur.origine = "erreur update Paramun - @paramun.id=" + params[:id].to_s
              @erreur.numLigne = '124'
              @erreur.message = e.message
              @erreur.parametreId = params[:id].to_s
              @erreur.save
              @updateOK = 1
          end
          respond_to do |format|
              case @updateOK
                  when 0
                      format.xml { render request.format.to_sym => "pparametreOKDep" }
                  when 1
                      format.xml { render request.format.to_sym => "pparErreurU2" }
              end
          end
      end
      # Mise à jour de la Date des Seuils de Franchise
      if params[:typeMaj][:maj].to_s == 'UParSeuil'
          begin
              @paramun.update(paramun_params)
          rescue => e # Incident Save Paramun
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = "rails - ParamunsController - update"
              @erreur.origine = "erreur update Paramun - @paramun.id=" + params[:id].to_s
              @erreur.numLigne = '147'
              @erreur.message = e.message
              @erreur.parametreId = params[:id].to_s
              @erreur.save
              @updateOK = 1
          end
          respond_to do |format|
              case @updateOK
                  when 0
                      format.xml { render request.format.to_sym => "pparametreOKDep" }
                  when 1
                      format.xml { render request.format.to_sym => "pparErreurU2" }
              end
          end
      end
  end


  # DELETE /paramuns/1
  # DELETE /paramuns/1.json
  def destroy     
      @dateDuJour = Time.now
      @current_time = Time.now
      @majParamun = 0
      @cptProjet = 0 # décompte des projets en dépassement de franchise
      ## Si Déconnexion de l'Application ######################################
      if params[:parametre][:maj] == 'DA'
          @erreurArchivage = 0
          @archivageOK = 0
          @nbreProjetArchiver = 0
          ## Examen des Projets ----------------------------------------------
          @paramun = Paramun.find(params[:id])
          @parDepassArray = @paramun.parDepass.split(",")
          @depassOK = 0
          if @parDepassArray[0].to_s != 'neant'
              if @parDepassArray[1].to_s == 'v' || (@parDepassArray[1].to_s !~ /\D/ && @parDepassArray[1].to_i > 0)
                  @depassOK = 1
              end
          end
          # Archivage des Projets 
          @paramun.projets.each do |projet|
              @archivageOK = 0
              @majProjet = 0
              if projet.taches.length != 0
                  ## MAJ des Suivi des Statuts **TACHE** et Incidence sur le Projet ---------------
                  proSuiviTac = [0,0,0,0]
                  projet.taches.each do |tache|
                      if tache.typetacNat.to_s == "FA"
                          if tache.tacStatut.slice(0,1) == "3"
                              proSuiviTac[3] = 1
                          else
                              tacDeadLine = DateTime.new(tache.tacDeadLine.slice(6,4).to_i, tache.tacDeadLine.slice(3,2).to_i, tache.tacDeadLine.slice(0,2).to_i)
                              dateMoins15 = tacDeadLine - 15
                              if @dateDuJour.strftime("%Y%m%d").to_i > tacDeadLine.strftime("%Y%m%d").to_i
                                  tache.tacStatut[0] = "2"
                                  proSuiviTac[2] = 1
                              else
                                  if @dateDuJour.strftime("%Y%m%d").to_i >= dateMoins15.strftime("%Y%m%d").to_i
                                      tache.tacStatut[0] = "1"
                                      proSuiviTac[1] = 1
                                  else
                                      tache.tacStatut[0] = "0"
                                      proSuiviTac[0] = 1
                                  end
                              end
                              tache.save
                          end
                          projet.proSuiviTac = proSuiviTac.join(',')
                          @majProjet = 1
                      end
                  end
              end
              ## MAJ des Suivi des Statuts **FACTURE** et Incidence sur le Projet -----------------
              if projet.factures.length != 0
                  @cptFacture = 0 # décompte des factures en dépassement de franchise
                  proSuiviFac = [0,0,0,0]
                  projet.factures.each do |facture|
                      @majFacture = 0
                      if facture.facStatut.slice(0,1) == "3"
                          proSuiviFac[3] = 1
                      else
                          if facture.facStatut.to_s != "3Annulé"
                              facDateLimite = DateTime.new(facture.facDateLimite.slice(6,4).to_i, facture.facDateLimite.slice(3,2).to_i, facture.facDateLimite.slice(0,2).to_i)
                              dateMoins15 = facDateLimite - 15
                              if @dateDuJour.strftime("%Y%m%d").to_i > facDateLimite.strftime("%Y%m%d").to_i
                                  facture.facStatut[0] = "2"
                                  proSuiviFac[2] = 1
                              else
                                  if @dateDuJour.strftime("%Y%m%d").to_i >= dateMoins15.strftime("%Y%m%d").to_i
                                      facture.facStatut[0] = "1"
                                      proSuiviFac[1] = 1
                                  else
                                      facture.facStatut[0] = "0"
                                      proSuiviFac[0] = 1
                                  end
                              end
                              @majFacture = 1
                              projet.proSuiviFac = proSuiviFac.join(',')
                              @majProjet = 1
                          end
                      end
                      # Situation de la Facture au regard du Dépassement du Seuil de la Franchise -------
                      if @depassOK == 1
                          if ['20', '40', '41', '50', '51'].include?(facture.typeImpr.to_s)
                              if facture.facStatut != '3Annulé'
                                  if facture.facDateEmis.slice(3,7) == @parDepassArray[0].to_s
                                      if facture.facmontTva.to_i == 0
                                          facture.facDepass = '1'
                                          @cptFacture += 1
                                      else
                                          facture.facDepass = '0'
                                      end
                                  else
                                      facture.facDepass = '0'
                                  end
                              else
                                  facture.facDepass = '0'
                              end
                              @majFacture = 1
                          end
                      end
                      # Maj de la facture
                      if @majFacture == 1
                          facture.save
                      end
                  end
              end
              # Situation du Projet au regard du Dépassement du Seuil de la Franchise
              if @depassOK == 1
                  if @cptFacture > 0
                      projet.proDepass = '1'
                      @cptProjet += 1
                  else
                      projet.proDepass = '0'
                  end
                  @majProjet = 1
              end
              ## MAJ éventuelle de l'occurrence de Projet -----------------------
              if @majProjet == 1
                  begin
                      projet.save
                  rescue => e  # erreur Save Projet
                      @erreur = Erreur.new
                      @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                      @erreur.appli = "rails - ProjetsController - index"
                      @erreur.origine = "erreur Save Projet - projet.id=" + projet.id.to_s
                      @erreur.numLigne = '89'
                      @erreur.message = e.message
                      @erreur.parametreId = params[:id].to_s
                      @erreur.save
                      @erreurSaveProjet = 1
                  end
              end
              ## Examen de l'Archivage du Projet --------------------------
              @archivageOK = 0
              if projet.taches.length != 0
                  regle = 1
                  cpt = 0
                  projet.taches.each do |tache|
                      if tache.typetacNat.to_s == "FA"
                          cpt += 1
                          if tache.tacStatut != '3Réglé'
                              regle = 0
                              break
                          end
                      end
                  end
                  if cpt > 0 && regle == 1
                      projet.proSituation = '22' # Clos -----
                      @archivageOK = 1
                      @nbreProjetArchiver += 1
                  end
              end
              if @archivageOK == 0 # Si 'Inactifs depuis +6mois' ----
                  t = Time.now
                  dateJour = t.strftime("%d") + '/' + t.strftime("%m") + '/' + t.strftime("%Y")
                  @dateDuJour = Date.parse(dateJour)
                  majDate = Date.parse(projet.majDate.to_s)
                  dureeJ = @dateDuJour - majDate
                  if dureeJ.to_i  > 180
                      @archivageOK = 1
                      @nbreProjetArchiver += 1
                  end
              end
              if @archivageOK == 1
                  if @nbreProjetArchiver == 1
                      begin
                          @paramunold = Paramunold.find(params[:id])
                      rescue ActiveRecord::RecordNotFound
                          @paramunold = Paramunold.new()
                          @paramunold.id = @paramun.id
                          @paramunold.save
                      end
                  end
                  if projet.proDepass.to_s == '1'
                       @cptProjet -= 1
                  end
                  # Archivage du Projet
                  @projetold = Projetold.new()
                  @projetold.id = projet.id
                  @projetold.proLib = projet.proLib
                  @projetold.proDateDeb = projet.proDateDeb
                  @projetold.proDeadLine = projet.proDeadLine
                  @projetold.proSuiviTac = projet.proSuiviTac
                  @projetold.proSuiviFac = projet.proSuiviFac
                  @projetold.proNumRang = projet.proNumRang
                  @projetold.proCliRaisonFacture = projet.proCliRaisonFacture
                  @projetold.proCliRaisonProjet = projet.proCliRaisonProjet
                  @projetold.proDureeBdc = projet.proDureeBdc
                  @projetold.proDureeExec = projet.proDureeExec
                  @projetold.proPourExec = projet.proPourExec
                  @projetold.proCaHt = projet.proCaHt
                  @projetold.proFacHt = projet.proFacHt
                  @projetold.proReglMont = projet.proReglMont
                  @projetold.proReport = projet.proReport
                  @projetold.proCout = projet.proCout
                  @projetold.proMarge = projet.proMarge
                  @projetold.proSituation = projet.proSituation
                  @projetold.proCliString = projet.proCliString
                  @projetold.proDepass = projet.proDepass
                  @projetold.majDate = projet.majDate
                  @projetold.clienteleFactureId = projet.clienteleFactureId
                  @projetold.clienteleProjetId = projet.clienteleProjetId
                  @projetold.parametreoldId = projet.parametreId
                  begin
                      @projetold.save
                  rescue => e # erreur Projetold Create
                      @erreur = Erreur.new
                      @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                      @erreur.appli = 'rails - ParamunsController - destroy'
                      @erreur.origine = 'Incident Save Projetold - projet.id=' + projet.id.to_s
                      @erreur.numLigne = '145'
                      @erreur.message = e.message
                      @erreur.parametreId = params[:id].to_s
                      @erreur.save
                      @erreurArchivage = 1
                      break
                  end
                  # Archivage des tachesold du Projetold
                  if @erreurArchivage == 0
                      if projet.taches.length != 0
                          projet.taches.each do |tache|
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
                              @tacheold.tacStNomPre = tache.tacStNomPre
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
                              rescue => e # erreur Tacheold Save
                                  @erreur = Erreur.new
                                  @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                                  @erreur.appli = 'rails - ParamunsController - destroy'
                                  @erreur.origine = 'Incident Save Tacheold - tache.id=' + tache.id.to_s
                                  @erreur.numLigne = '145'
                                  @erreur.message = e.message
                                  @erreur.parametreId = params[:id].to_s
                                  @erreur.save
                                  @erreurArchivage = 1
                                  break
                              end
                          end
                      end
                  end
                  # Archivage des facturesold du Projetold
                  if @erreurArchivage == 0
                      if projet.factures.length != 0
                          projet.factures.each do |facture|
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
                              @factureold.facImput = facture.facImput
                              @factureold.facDifference = facture.facDifference
                              @factureold.facTotalDu = facture.facTotalDu
                              @factureold.modePaieLib = facture.modePaieLib
                              @factureold.facReglMont = facture.facReglMont
                              @factureold.facStringLigne = facture.facStringLigne
                              @factureold.majTache = facture.majTache
                              @factureold.facDepass = facture.facDepass
                              @factureold.projetoldId = facture.projetId
                              @factureold.parametreoldId = facture.parametreId
                              begin
                                  @factureold.save
                              rescue => e # erreur Factureold Create
                                  @erreur = Erreur.new
                                  @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                                  @erreur.appli = 'rails - ParamunsController - destroy'
                                  @erreur.origine = 'Incident Save Factureold - facture.id=' + facture.id.to_s
                                  @erreur.numLigne = '145'
                                  @erreur.message = e.message
                                  @erreur.parametreId = params[:id].to_s
                                  @erreur.save
                                  @erreurArchivage = 1
                                  break
                              end
                          end
                      end
                  end
                  # Suppression des Tache du Projet ---
                  if @erreurArchivage == 0
                      if projet.taches.length != 0
                          projet.taches.each do |tache|
                               begin
                                  tache.destroy
                              rescue => e  # Incident destroy Tache
                                  @erreur = Erreur.new
                                  @erreurdateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                                  @erreur.appli = 'rails - ParamunsController - destroy'
                                  @erreur.origine = "erreur destroy Tache - tache.id =" + tache.id.to_s
                                  @erreur.numLigne = '216'
                                  @erreur.message = e.message
                                  @erreur.parametreId = params[:id].to_s
                                  @erreur.save
                                  @erreurArchivage = 1
                              end
                          end
                      end
                  end
                  # Suppression des Facture du Projet ---
                  if @erreurArchivage == 0
                      if projet.factures.length != 0
                          projet.factures.each do |facture|
                              begin
                                  facture.destroy
                              rescue => e  # Incident destroy Facture
                                  @erreur = Erreur.new
                                  @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                                  @erreur.appli = 'rails - ParamunsController - destroy'
                                  @erreur.origine = "erreur destroy Facture - facture.id =" + facture.id.to_s
                                  @erreur.numLigne = '236'
                                  @erreur.message = e.message
                                  @erreur.parametreId = params[:id].to_s
                                  @erreur.save
                                  @erreurArchivage = 1
                              end
                          end
                      end
                  end
                  # Suppression du Projet ---
                  if @erreurArchivage == 0
                      begin
                          projet.destroy
                      rescue => e  # Incident destroy Projet
                          @erreur = Erreur.new
                          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                          @erreur.appli = 'rails - ParamunsController - destroy'
                          @erreur.origine = "erreur destroy Projet - projet.id =" + projet.id.to_s
                          @erreur.numLigne = '254'
                          @erreur.message = e.message
                          @erreur.parametreId = params[:id].to_s
                          @erreur.save
                      end
                  end
              end # --- Fin de l'examen d'une occurrence de Projet ---
          end ### FIN de L'examen de toutes les occurrences de Projet ----------------------------
          # Si Archivage des Projets -------------
          if @nbreProjetArchiver > 0
              nbreDevisInactif = 0
              nbreProjetInactif = 0
              nbreProjetClos = 0
              @paramunold.projetolds.each do |projetold|
                  case projetold.proSituation.to_s
                      when '20'
                          nbreDevisInactif += 1
                      when '21'
                          nbreProjetInactif += 1
                      when '22'
                          nbreProjetClos += 1
                  end
              end
              @paramun.nbreDevisInactif = nbreDevisInactif.to_s
              @paramun.nbreProjetInactif = nbreProjetInactif.to_s
              @paramun.nbreProjetClos = nbreProjetClos.to_s
              @majParamun = 1
          end 
          # Situation de Paramun au regard du Dépassement du Seuil de la Franchise
          if @depassOK == 1
              if @cptProjet == 0
                  @paramun.parDepass = "neant,v"
              else
                  depass = @parDepassArray[0].to_s + ',' + @cptProjet.to_s
                  @paramun.parDepass = depass
              end
              @majParamun = 1
          end
          if @majParamun == 1
              @paramun.save
          end

          ## Examen des Types de Tache ------------------------------
          @typetacheArray = params[:parametre][:typetacheString].split(",")
          if @typetacheArray.length != 0 ## si au moins une Typetache à actualiser
              @typetacheArray.uniq!
              for t in @typetacheArray
                  begin
                      @typetache = Typetache.find(t)
                      if @typetache.typetacNat.to_s == 'FA'
                          @calTypetacMarge = 0
                          @margeCumul = 0
                          @nbreTache = 0
                          @typetache.taches.each do |tache|
                              if tache.tacStatut.to_s == "3Facturé" || tache.tacStatut.to_s == "3miFacturé" || tache.tacStatut.to_s == "3Réglé"
                                  ## Re-Calcul des marges type ---------
                                  @margeCumul += tache.tacMarge.to_i
                                  @nbreTache += 1
                              end
                          end
                          if @nbreTache > 0
                              @calTypetacMarge = ((@margeCumul / @nbreTache) * 100).to_i
                              @typetache.typetacMarge = @calTypetacMarge.to_s
                              @typetache.typetacMarge = @calTypetacMarge.round.to_s
                              begin
                                  @typetache.save
                              rescue => e  # incident Save Typetache
                                  @erreur = Erreur.new
                                  @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                                  @erreur.appli = 'rails - ParametresController - destroy'
                                  @erreur.origine = "erreur Save Typetache.id= " + t.to_s
                                  @erreur.numLigne = '86'
                                  @erreur.message = e.message
                                  @erreur.parametreId = params[:id].to_s
                                  @erreur.save
                                  break
                              end
                          end
                      end
                  rescue => e  # Incident Find Typetache
                      @erreur = Erreur.new
                      @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                      @erreur.appli = 'rails - ParamunsController - destroy'
                      @erreur.origine = "erreur Find Typetache.id= " + t.to_s
                      @erreur.numLigne = '86'
                      @erreur.message = e.message
                      @erreur.parametreId = params[:id].to_s
                      @erreur.save
                      break
                  end
              end
          end ## FIN Examen des Types de Tache ------------------------------

          ## Fermeture de l'Application -----------------------------------
          head :no_content

      else ## Suppression d'une occurrence de Paramun #####################################
          ## en chantier *****************
          @paramun.destroy
          redirect_to parametres_url, notice: 'Parametre was successfully destroyed.'
      end
  end

  private
    # Only allow a trusted parameter "white list" through.
    def paramun_params
      params.require(:parametre).permit!
    end

end
