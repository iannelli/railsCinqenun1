class ParamunsController < ApplicationController
  # VERIFICATION de la Connexion *******************
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
      @majNewAn = '0'
      begin
          @paramun = Paramun.find(params[:parametre][:id])
          @anCourant = Time.new.year
          moisCourant = Time.new.month
          anMoins2 = @anCourant - 2
          # Traitement de Changement d'année : Ré-Initialisation et Archivage des Recettes/Dépenses/Immobs
          if @anCourant > @paramun.parDateConnex.slice(0,4).to_i
              # parMaj
              @majNewAn = '1'
              # parDepass ----
              @paramun.parDepass = "neant,v"
              # parRecette ----------------------------------------
              @parRecetteNewArray = [0,0,0,0,0,0,0]
              @parRecetteOldArray = @paramun.parRecette.split(',')
              @parRecetteNewArray[1] = @parRecetteOldArray[0]
              @parRecetteNewArray[2] = @parRecetteOldArray[1]
              @parRecetteNewArray[3] = @parRecetteOldArray[2]
              @parRecetteNewArray[4] = @parRecetteOldArray[3]
              @parRecetteNewArray[5] = @parRecetteOldArray[4]
              @parRecetteNewArray[6] = @parRecetteOldArray[5]
              @paramun.parRecette = @parRecetteNewArray.join(',')
              # nbreRecette -----
              @nbreRecetteNewArray = [0,0,0,0,0,0,0]
              @nbreRecetteOldArray = @paramun.nbreRecette.split(',')
              @nbreRecetteNewArray[1] = @nbreRecetteOldArray[0]
              @nbreRecetteNewArray[2] = @nbreRecetteOldArray[1]
              @nbreRecetteNewArray[3] = @nbreRecetteOldArray[2]
              @nbreRecetteNewArray[4] = @nbreRecetteOldArray[3]
              @nbreRecetteNewArray[5] = @nbreRecetteOldArray[4]
              @nbreRecetteNewArray[6] = @nbreRecetteOldArray[5]
              @paramun.nbreRecette = @nbreRecetteNewArray.join(',')
              # parDepense ---------------------------------------
              @parDepenseNewArray = [0,0,0,0,0,0,0]
              @parDepenseOldArray = @paramun.parDepense.split(',')
              @parDepenseNewArray[1] = @parDepenseOldArray[0]
              @parDepenseNewArray[2] = @parDepenseOldArray[1]
              @parDepenseNewArray[3] = @parDepenseOldArray[2]
              @parDepenseNewArray[4] = @parDepenseOldArray[3]
              @parDepenseNewArray[5] = @parDepenseOldArray[4]
              @parDepenseNewArray[6] = @parDepenseOldArray[5]
              @paramun.parDepense = @parDepenseNewArray.join(',')
              # nbreDepense -----
              @nbreDepenseNewArray = [0,0,0,0,0,0,0]
              @nbreDepenseOldArray = @paramun.nbreDepense.split(',')
              @nbreDepenseNewArray[1] = @nbreDepenseOldArray[0]
              @nbreDepenseNewArray[2] = @nbreDepenseOldArray[1]
              @nbreDepenseNewArray[3] = @nbreDepenseOldArray[2]
              @nbreDepenseNewArray[4] = @nbreDepenseOldArray[3]
              @nbreDepenseNewArray[5] = @nbreDepenseOldArray[4]
              @nbreDepenseNewArray[6] = @nbreDepenseOldArray[5]
              @paramun.nbreDepense = @nbreDepenseNewArray.join(',')
              # parImmob ---------------------------------------
              @parImmobNewArray = [0,0,0,0,0,0,0]
              @parImmobOldArray = @paramun.parImmob.split(',')
              if @paramun.immobs.length != 0
                  @paramun.immobs.each do |immob|
                      @imAmorArray = immob.imAmorString.split("|")
                      i = 0
                      while i < @imAmorArray.length
                          exerImmob = @imAmorArray[i+1].to_i
                          if exerImmob == @anCourant-1
                              parImmob = @parImmobOldArray[0].to_i + @imAmorArray[i+2].to_i
                              @parImmobOldArray[0] = parImmob.to_s
                              break
                          end
                          i += 5
                      end
                  end
              end
              @parImmobNewArray[1] = @parImmobOldArray[0]
              @parImmobNewArray[2] = @parImmobOldArray[1]
              @parImmobNewArray[3] = @parImmobOldArray[2]
              @parImmobNewArray[4] = @parImmobOldArray[3]
              @parImmobNewArray[5] = @parImmobOldArray[4]
              @parImmobNewArray[6] = @parImmobOldArray[5]
              @paramun.parImmob = @parImmobNewArray.join(',')
              # Archivage des Recettes de l'année N-2 ------------
              if @paramun.recettes.length != 0
                  @paramun.recettes.each do |recette|
                      if recette.facDateReception.slice(6,4) == anMoins2.to_s
                          @recetteold = Recetteold.new()
                          @recetteold.id = recette.id
                          @recetteold.facDateEmis = recette.facDateEmis
                          @recetteold.facDateReception = recette.facDateReception
                          @recetteold.facRef = recette.facRef
                          @recetteold.cliRaison = recette.cliRaison
                          @recetteold.proLib = recette.proLib
                          @recetteold.montantHt = recette.montantHt
                          @recetteold.montantTva = recette.montantTva
                          @recetteold.facReglMont = recette.facReglMont
                          @recetteold.modePaieLib = recette.modePaieLib
                          @recetteold.tvaDecla = recette.tvaDecla
                          @recetteold.tvaPeriode = recette.tvaPeriode
                          @recetteold.lignesTva = recette.lignesTva
                          @recetteold.factureId = recette.factureId
                          @recetteold.parametreoldId = recette.parametreId
                          @recetteold.save
                          recette.destroy
                      end
                  end
              end
              # Archivage des Depenses de l'année N-2 ----------------
              if @paramun.depenses.length != 0
                  @paramun.depenses.each do |depense|
                      if depense.dateRegl.slice(6,4) == anMoins2.to_s
                          @depenseold = Depenseold.new()
                          @depenseold.id = depense.id
                          @depenseold.dateRegl = depense.dateRegl
                          @depenseold.refFacture = depense.refFacture
                          @depenseold.libelle = depense.libelle
                          @depenseold.nature = depense.nature
                          @depenseold.fournisseur = depense.fournisseur
                          @depenseold.pays = depense.pays
                          @depenseold.montantFactHt = depense.montantFactHt
                          @depenseold.usagePro = depense.usagePro
                          @depenseold.montantHt = depense.montantHt
                          @depenseold.montantTva = depense.montantTva
                          @depenseold.montantTtc = depense.montantTtc
                          @depenseold.tauxTva = depense.tauxTva
                          @depenseold.tauxTvaAutre = depense.tauxTvaAutre
                          @depenseold.modeRegl = depense.modeRegl
                          @depenseold.typeDecla = depense.typeDecla
                          @depenseold.tvaDecla = depense.tvaDecla
                          @depenseold.tvaPeriode = depense.tvaPeriode
                          @depenseold.lignesTva = depense.lignesTva
                          @depenseold.parametreoldId = depense.parametreId
                          @depenseold.save
                          depense.destroy
                      end
                  end
              end
              # Maj de parAnFac et parNumFact -----------
              @paramun.parAnFact = anCourant.to_s
              @paramun.parNumFact = '00000'
          end
          # Maj de parDateConnex -----------
          @paramun.parDateConnex = (@current_time.strftime "%Y%m%d%H%M%S").to_s #Date-Heure Connexion 'aaaammjjhhmnss'
          # Maj parMaj (changement d'Année) ----
          majNewAnB = @majNewAn + @paramun.parMaj.slice(1,1).to_s
          @paramun.parMaj = majNewAnB
          @paramun.save
      rescue => e # Incident Find de Paramun
          @erreur = Erreur.new
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = "rails - ParamunsController - index"
          @erreur.origine = "erreur Find Paramun - params[:parametre][:id]=" + params[:parametre][:id].to_s
          @erreur.numLigne = '24'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:id].to_i
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



  # PATCH/PUT /paramuns/1
  # PATCH/PUT /paramuns/1.json
  def update
      @updateOK = 0
      @current_time = DateTime.now
      # Mise à jour des Données Parametre et Identification Abonne -------
      if params[:typeMaj][:maj].to_s == 'UParAbonne'
          if params[:typeMaj][:par].to_s == '1'
              begin
                  @paramun.update(paramun_params)
                  @updateOK += 10 # @updateOK = 10
              rescue => e # Incident Save Paramun
                  @erreur = Erreur.new
                  @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                  @erreur.appli = "rails - ParamunsController - update"
                  @erreur.origine = "erreur update Paramun - @paramun.id=" + params[:id].to_s
                  @erreur.numLigne = '193'
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
                  @abonne.aboSeuilBase = params[:abonne][:seuilBase].to_s
                  @abonne.aboSeuilMajo = params[:abonne][:seuilMajo].to_s
                  begin
                      @abonne.save
                      @updateOK += 10 # @updateOK = 10 ou 20
                  rescue => e # Incident Save Paramun
                      @erreur = Erreur.new
                      @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                      @erreur.appli = "rails - ParamunsController - update"
                      @erreur.origine = "erreur update Abonne - @abonne.id=" + params[:id].to_s
                      @erreur.numLigne = '214'
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
      # Mise à jour des Données de la FranchiseTVA suite à l'Ouverture de Cinqenun  ---------------
      if params[:typeMaj][:maj].to_s == 'UParFranchiseOuverture'
          begin
              @paramun.update(paramun_params)
          rescue => e # Incident Save Paramun
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = "rails - ParamunsController - update"
              @erreur.origine = "erreur update Paramun - @paramun.id=" + params[:id].to_s
              @erreur.numLigne = '245'
              @erreur.message = e.message
              @erreur.parametreId = params[:id].to_s
              @erreur.save
              @updateOK = 1
          end
          if @updateOK == 0
              @abonne = Abonne.find(params[:id])
              @abonne.aboSeuilBase = params[:abonne][:seuilBase].to_s
              @abonne.aboSeuilMajo = params[:abonne][:seuilMajo].to_s
              begin
                  @abonne.save
              rescue => e # Incident Save Paramun
                  @erreur = Erreur.new
                  @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                  @erreur.appli = "rails - ParamunsController - update"
                  @erreur.origine = "erreur update Abonne - @abonne.id=" + params[:id].to_s
                  @erreur.numLigne = '262'
                  @erreur.message = e.message
                  @erreur.parametreId = params[:id].to_s.to_s
                  @erreur.save
                  @updateOK = 2
              end
          end
          respond_to do |format|
              case @updateOK
                  when 0
                      format.xml { render request.format.to_sym => "pparametreOKFra" }
                  when 1, 2
                      format.xml { render request.format.to_sym => "pparErreurU2" }
              end
          end
      end
      # Mise à jour des Données de la FranchiseTVA suite à la saisie du Règlement d'une Facture  ---------------
      if params[:typeMaj][:maj].to_s == 'UParFranchiseImposition'
          begin
              @paramun.update(paramun_params)
          rescue => e # Incident Save Paramun
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = "rails - ParamunsController - update"
              @erreur.origine = "erreur update Paramun - @paramun.id=" + params[:id].to_s
              @erreur.numLigne = '287'
              @erreur.message = e.message
              @erreur.parametreId = params[:id].to_s
              @erreur.save
              @updateOK = 1
          end
          respond_to do |format|
              case @updateOK
                  when 0
                      format.xml { render request.format.to_sym => "pparametreOKFra" }
                  when 1
                      format.xml { render request.format.to_sym => "pparErreurU3" }
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
          ## Examen des Conditions de Dépassement de la Franchise TVA ----------------------------------------------
          @paramun = Paramun.find(params[:id])
          @parDepassArray = @paramun.parDepass.split(",")
          @depassOK = 0
          if @parDepassArray[0].to_s != 'neant'
              if @parDepassArray[1].to_s == 'v'
                  @depassOK = 1
              else 
                  if @parDepassArray[1].to_i > 0
                       @depassOK = 1
                  end
              end
          end

          ## TRAITEMENT DES PROJETS **************************
          if @paramun.projets.length != 0
              ## Examen des Projets ----------------------------------------------
              @paramun.projets.each do |projet|
                  @archivageOK = 0
                  @majProjet = 0
                  ## MAJ des Suivi des Statuts **TACHE** et Incidence sur le Projet ---------------
                  if projet.taches.length != 0
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
                  end # FIN de l'examen des occurrences de Tache du Projet
                  ## MAJ des Suivi des Statuts **FACTURE** et Incidence sur le Projet -----------------
                  if projet.factures.length != 0
                      @cptFacture = 0 # décompte des factures en dépassement de franchise
                      proSuiviFac = [0,0,0,0]
                      projet.factures.each do |facture|
                          @majFacture = 0
                          if facture.facStatut.slice(0,1) == "3"
                              proSuiviFac[3] = 1
                          else
                              if facture.facStatut.to_s != "3Annulé" && facture.facStatut.to_s != "3Imputé"
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
                                  if facture.facStatut.to_s != '3Annulé'
                                      anMoisEmission = facture.facDateEmis.slice(6,4).to_s + facture.facDateEmis.slice(3,2).to_s
                                      if anMoisEmission.to_i >= @parDepassArray[0].to_i
                                          if facture.facMontTva.to_i > 0
                                              facture.facDepass = '0'
                                              facture.save
                                          else
                                              facture.facDepass = '1'
                                              facture.save
                                              @cptFacture += 1
                                          end
                                      else
                                          facture.facDepass = '0'
                                          facture.save
                                      end
                                  else
                                      facture.facDepass = '0'
                                      facture.save
                                  end
                              end
                          end
                          # Maj de la facture
                          if @majFacture == 1
                              facture.save
                          end
                      end
                  end # FIN de l'examen des occurrences de facture du Projet
                  # Situation du Projet au regard du Dépassement du Seuil de la Franchise ---------------------------
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
                          @erreur.numLigne = '442'
                          @erreur.message = e.message
                          @erreur.parametreId = params[:id].to_s
                          @erreur.save
                          @erreurSaveProjet = 1
                      end
                  end
                  ## Examen des Conditions d'Archivage du Projet --------------------------
                  @archivageOK = 0
                  if projet.proDepass.to_s == '0'
                      if projet.proReport.to_i == 0
                          if projet.taches.length != 0
                              regle = 1
                              cpt = 0
                              projet.taches.each do |tache|
                                  if tache.typetacNat.to_s == "FA"
                                      cpt += 1
                                      if tache.tacStatut == '3miFacturé'
                                          @tacFacArray = []
                                          @tacFacArray = tache.tacFacString.split('|')
                                          i = 2
                                          while (i < @tacFacArray.length)
                                              if @tacFacArray[i].to_s != 'R'
                                                  regle = 0
                                                  break
                                              else
                                                  i += 5
                                              end
                                          end
                                      else
                                          if tache.tacStatut != '3Réglé'
                                              regle = 0
                                              break
                                          end
                                      end
                                  end
                              end
                              if cpt > 0 && regle == 1
                                  projet.proSituation = '22' ## Projet Clos *****
                                  @archivageOK = 1
                                  @nbreProjetArchiver += 1
                              end
                          end
                      end
                      if @archivageOK == 0 # Si Projet 'non Clos' ----------------
                          t = Time.now
                          dateJour = t.strftime("%d") + '/' + t.strftime("%m") + '/' + t.strftime("%Y")
                          @dateDuJour = Date.parse(dateJour)
                          majDate = Date.parse(projet.majDate.to_s)
                          dureeJ = @dateDuJour - majDate
                          if dureeJ.to_i  > 180 ## Si 'projet 'Inactif' depuis +6mois ----
                              situation = '2' + projet.proSituation.slice(1,1)
                              projet.proSituation = situation ## Devis EnAttente Inactif ou Projet enCours Inactif ****
                              @archivageOK = 1
                              @nbreProjetArchiver += 1
                          end
                      end
                  end
                  ## Si Archivage OK -------------------
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
                      # Archivage du Projet --------------------------
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
                          @erreur.numLigne = '530'
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
                                      @erreur.numLigne = '585'
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
                                      @erreur = Erreur.new
                                      @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                                      @erreur.appli = 'rails - ParamunsController - destroy'
                                      @erreur.origine = 'Incident Save Factureold - facture.id=' + facture.id.to_s
                                      @erreur.numLigne = '637'
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
                                      @erreur.numLigne = '658'
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
                                      @erreur.numLigne = '678'
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
                              @erreur.numLigne = '696'
                              @erreur.message = e.message
                              @erreur.parametreId = params[:id].to_s
                              @erreur.save
                          end
                      end
                  end # --- Fin de l'examen d'une occurrence de Projet ---
              end ### FIN de l'examen de toutes les occurrences de Projet ----------------------------

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
                      anMoisCourant = @current_time.strftime "%Y%m"
                      if anMoisCourant.to_i > @parDepassArray[0].to_i
                          @paramun.parDepass = "neant,v"
                      end
                  else
                      depass = @parDepassArray[0].to_s + ',' + @cptProjet.to_s
                      @paramun.parDepass = depass
                  end
                  @majParamun = 1
              end
              if @majParamun == 1
                  @paramun.save
              end
          end ## FIN du Traitement des Projets ------


          ## Examen des Types de Tache ------------------------------
          @typetacheArray = params[:parametre][:typetacheString].split(",")
          if @typetacheArray.length != 0 ## si au moins un Typetache à actualiser
              @typetacheArray.uniq! #Unification des id de même valeur en un seul id
              for t in @typetacheArray
                  begin
                      @typetache = Typetache.find(t)
                      if @typetache.typetacNat.to_s == 'FA'
                          @margeCumul = 0
                          @margeMoy1 = 0
                          @margeMoy2 = 0
                          @tempsArray = [0,0]
                          @nbreHH = 0
                          @nbreMN = 0
                          @totDuree = 0
                          if @typetache.taches.length == 0
                              @typetache.typetacMarge = '0'
                              @typetache.save
                          else 
                              @typetache.taches.each do |tache|
                                  ## Re-Calcul des marges type ---------
                                  @margeCumul += tache.tacMarge.to_i
                                  @tempsArray = tache.tacDureeBdc.split(':')
                                  @nbreHH += @tempsArray[0].to_i
                                  @nbreMN += @tempsArray[1].to_i
                              end
                              @totDuree = @nbreHH + (@nbreMN / 60)
                              if @totDuree > 0
                                  @margeMoy1 = @margeCumul / @totDuree
                                  @margeMoy2 = (@typetache.typetacMarge.to_i + @margeMoy1) / 2
                                  @typetache.typetacMarge = @margeMoy2.round.to_s
                              else
                                  @typetache.typetacMarge = '000'
                              end
                              @typetache.save
                          end
                      end
                  rescue => e  # Incident Find Typetache
                      @erreur = Erreur.new
                      @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                      @erreur.appli = 'rails - ParamunsController - destroy'
                      @erreur.origine = "erreur Find Typetache.id= " + t.to_s
                      @erreur.numLigne = '757'
                      @erreur.message = e.message
                      @erreur.parametreId = params[:id].to_s
                      @erreur.save
                      break
                  end
              end
          end ## FIN Examen des Types de Tache ------------------------------

          ## Constitution des Statistiques de Suivi (pour l'Ecran d'Accueil) ############
          statRecetteAccueilArray = []
          statDepenseAccueilArray = []
          statFactureAccueilArray = []
          sixDernierMoisArray = []
          if @dateDuJour.day < 15
              @mm = @dateDuJour.month - 1
              if @mm.to_i == 0
                  @aaaa = @dateDuJour.year - 1
                  @mm = '12'
              else
                  @aaaa = @dateDuJour.year
              end
          else
              @aaaa = @dateDuJour.year
              @mm = @dateDuJour.month
          end
          sixDernierMoisArray[0] = @aaaa.to_s + "%02d" % @mm.to_i
          m=1
          while m<6
              @mm = @mm.to_i - 1
              if @mm.to_i == 0
                  @mm = 12
                  @aaaa = @aaaa.to_i - 1
              end
              sixDernierMoisArray[m] = @aaaa.to_s + "%02d" % @mm.to_i
              m += 1
          end
          ## Initialisation des 3 Arrays -----
          m=0
          rd=0
          f=0
          while m<6
              statRecetteAccueilArray[rd] = sixDernierMoisArray[m]
              statDepenseAccueilArray[rd] = sixDernierMoisArray[m]
              statFactureAccueilArray[f] = sixDernierMoisArray[m]
              rd += 1
              f += 1
              statRecetteAccueilArray[rd] = '0'
              statDepenseAccueilArray[rd] = '0'
              statFactureAccueilArray[f] = '0'
              f += 1
              statFactureAccueilArray[f] = '0'
              rd += 1
              f += 1
              m += 1
          end
          statFactureAccueilArray[f] = 'antérieur'
          statFactureAccueilArray[f+1] = '0'
          statFactureAccueilArray[f+2] = '0'
          ## Recette : Collecte des données pour implémentation dans les Array respectives -------------------
          ## Examen des Recettes -------
          if @paramun.recettes.length != 0
              @paramun.recettes.each do |recette|
                  aaaamm = recette.facDateReception.slice(6,4) + recette.facDateReception.slice(3,2)
                  ind = statRecetteAccueilArray.find_index(aaaamm)
                  if ind != nil
                      ind +=1
                      montant1 = statRecetteAccueilArray[ind].to_i
                      montant2 = recette.montantHt.to_i / 100
                      statRecetteAccueilArray[ind] = montant1 + montant2.to_i
                  end
              end
          end
          ## Examen des Dépenses -------
          if @paramun.depenses.length != 0
              @paramun.depenses.each do |depense|
                  aaaamm = depense.dateRegl.slice(6,4) + recette.dateRegl.slice(3,2)
                  ind = statDepenseAccueilArray.find_index(aaaamm)
                  if ind != nil
                      ind +=1
                      montant1 = statDepenseAccueilArray[ind].to_i
                      montant2 = recette.montantHt.to_i / 100
                      statDepenseAccueilArray[ind] = montant1 + montant2.to_i 
                  end
              end
          end
          ## Examen des Factures impayées -------
          if @paramun.projets.length != 0
              ## Examen des Projets ------
              @paramun.projets.each do |projet|
                  if projet.factures.length != 0
                      projet.factures.each do |facture|
                          if (facture.typeImpr.to_s == '40' || facture.typeImpr.to_s == '41' || facture.typeImpr.to_s == '50' || facture.typeImpr.to_s == '51')
                              if (facture.facStatut.to_s != '3Réglé' && facture.facStatut.to_s != '3Annulé')
                                  aaaamm = facture.facDateEmis.slice(6,4) + facture.facDateEmis.slice(3,2)
                                  ind = statFactureAccueilArray.find_index(aaaamm)
                                  if ind == nil
                                      ind = 18
                                  end
                                  ind +=1
                                  montant1 = statFactureAccueilArray[ind].to_i
                                  montant2 = facture.facMontHt.to_i / 100
                                  statFactureAccueilArray[ind] = montant1 + montant2.to_i
                                  ind +=1
                                  nombre = statFactureAccueilArray[ind].to_i
                                  statFactureAccueilArray[ind] = nombre + 1
                              end
                          end
                      end
                  end
              end
          end
          ## Examen des Projetolds ------
          if @paramun.projets.length != 0
              @paramunold = Paramunold.find_by(id: @paramun.id)
              unless @paramunold.nil?             
                  if @paramunold.projetolds.length > 0
                      @paramunold.projetolds.each do |projetold|
                          if projetold.proSituation.to_s != '22'
                              if projetold.factureolds.length != 0
                                  projetold.factureolds.each do |factureold|
                                      if (factureold.typeImpr.to_s == '40' || factureold.typeImpr.to_s == '41' || factureold.typeImpr.to_s == '50' || factureold.typeImpr.to_s == '51')
                                          if (factureold.facStatut.to_s != '3Réglé' && factureold.facStatut.to_s != '3Annulé')
                                              aaaamm = factureold.facDateEmis.slice(6,4) + factureold.facDateEmis.slice(3,2)
                                              ind = statFactureAccueilArray.find_index(aaaamm)
                                              if ind == nil
                                                  ind = 18
                                              end
                                              ind +=1
                                              montant1 = statFactureAccueilArray[ind].to_i
                                              montant2 = factureold.facMontHt.to_i / 100
                                              statFactureAccueilArray[ind] = montant1 + montant2.to_i
                                              ind +=1
                                              nombre = statFactureAccueilArray[ind].to_i
                                              statFactureAccueilArray[ind] = nombre + 1
                                          end
                                      end
                                  end
                              end
                          end
                      end
                  end
              end
          end
          ## Enregistrement -----
          @paramun.statRecetteAccueil = statRecetteAccueilArray.join('|')
          @paramun.statDepenseAccueil = statDepenseAccueilArray.join('|')
          @paramun.statFactureAccueil = statFactureAccueilArray.join('|')
          @paramun.save
          ## FIN Constitution des Statistiques de Suivi ###########################

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
