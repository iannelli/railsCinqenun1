class ProjetclonesController < ApplicationController

  # TEST de Connexion *******************
  before_action :authenticate_rights
  def authenticate_rights
      dateConnex = params[:parametre][:parDateConnex]
      @paramun = Paramun.find(params[:parametre][:id].to_i)

      if dateConnex.to_i > @paramun.parDateConnex.to_i
          respond_to do |format|
              format.xml { render request.format.to_sym => "clpErreurS" }
          end
      end
  end


  # PUT /projetclones/1 ********* Clonage du Projet sélectionné ******************
  # PUT /projetclones/1.xml
  def update
      @current_time = DateTime.now
      @erreurCreateClone = 0
      begin
          if params[:parametre][:parTypeProjet].to_s == 'new'
              @projet = Projet.find(params[:id])
          else
              @projet = Projetold.find(params[:id])
          end
          @projetclone = Projet.new
          @projetclone.proLib = "clone**** " + @projet.proLib.slice(0,30)
          @projetclone.proDateDeb = @current_time.strftime "%d/%m/%Y"
          dateDeb = DateTime.new(@projetclone.proDateDeb.slice(6,4).to_i, @projetclone.proDateDeb.slice(3,2).to_i, @projetclone.proDateDeb.slice(0,2).to_i)
          datePlus30 = dateDeb + 30
          @projetclone.proDeadLine = datePlus30.strftime "%d/%m/%Y"
          @projetclone.proSuiviTac = "0,0,0,0"
          @projetclone.proSuiviFac = "0,0,0,0"
          @projetclone.proNumRang = "|-1||-1"
          @projetclone.proCliRaisonFacture = @projet.proCliRaisonFacture.to_s
          @projetclone.proCliRaisonProjet = @projet.proCliRaisonProjet.to_s
          @projetclone.proDureeBdc = "0:00"
          @projetclone.proDureeExec = "0:00"
          @projetclone.proPourExec = "0,00%"
          @projetclone.proSituation = "00"
          @projetclone.majDate = @current_time.strftime "%d/%m/%Y"
          @projetclone.clienteleFactureId = @projet.clienteleFactureId.to_s
          @projetclone.clienteleProjetId = @projet.clienteleProjetId.to_s
          @projetclone.parametreId = params[:parametre][:id].to_s
          begin 
              @projetclone.save
           rescue => e # Incident Création @projetclone
              @erreur = Erreur.new
              @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
              @erreur.appli = 'rails - ProjetclonesController - update'
              @erreur.origine = "Incident Création Projetclone - Projet.id = " + params[:id].to_s
              @erreur.numLigne = '45'
              @erreur.message = e.message
              @erreur.parametreId = params[:parametre][:id].to_s
              @erreur.save
              @erreurCreateClone = 1
          end
      rescue => e # Incident Find Projet
          @erreur = Erreur.new
          @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
          @erreur.appli = 'rails - ProjetclonesController - update'
          @erreur.origine = "Incident Find Projet.id = " + projet.id.to_s
          @erreur.numLigne = '22'
          @erreur.message = e.message
          @erreur.parametreId = params[:parametre][:id].to_s
          @erreur.save
          @erreurCreateClone = 1
      end
      if @erreurCreateClone == 0
          @taches = []
          if params[:parametre][:parTypeProjet].to_s == 'new'
              @taches = @projet.taches
          else
              @taches = @projet.tacheolds
          end
          if @taches.length > 0
              @taches.each do |tache|
                  @tacheclone = Tache.new
                  @tacheclone.famtacNum = tache.famtacNum
                  @tacheclone.typetacLib = tache.typetacLib
                  @tacheclone.tacCategorie = tache.tacCategorie
                  @tacheclone.tacLibCourt = "clone**** " + tache.tacLibCourt.slice(0,40)
                  @tacheclone.tacLibPeriode = tache.tacLibPeriode
                  @tacheclone.tacLibDetail = tache.tacLibDetail
                  @tacheclone.typetacNat = tache.typetacNat
                  @tacheclone.tacProLib = @projet.proLib
                  if tache.typetacNat = "FA"
                      @tacheclone.tacModeFac = "Acte"
                      @tacheclone.tacStatut = "0nonInitié"
                      @tacheclone.typetacUnite = tache.typetacUnite
                      @tacheclone.typetacTarifUnite = tache.typetacTarifUnite
                      @tacheclone.typetacET = tache.typetacET
                      @tacheclone.tacQuantUnitaire = tache.tacQuantUnitaire
                      @tacheclone.tacMont = tache.tacMont
                      @tacheclone.tacRemiseTaux = tache.tacRemiseTaux
                      @tacheclone.tacBdcHt = tache.tacBdcHt
                      @tacheclone.tacPeriodeNbre = "1"
                      @tacheclone.tacLibPeriode = ""
                      @tacheclone.tacPeriode = "A|.|.|."
                  end
                  @tacheclone.tacCoutHeure = tache.tacCoutHeure
                  @tacheclone.tacDateDeb = @current_time.strftime "%d/%m/%Y"
                  dateDeb = DateTime.new(@tacheclone.tacDateDeb.slice(6,4).to_i, @tacheclone.tacDateDeb.slice(3,2).to_i, @tacheclone.tacDateDeb.slice(0,2).to_i)
                  datePlus30 = dateDeb + 30
                  @tacheclone.tacDeadLine = datePlus30.strftime "%d/%m/%Y"
                  @tacheclone.tacTravail = ""
                  @tacheclone.tacQuantTotal = tache.tacQuantTotal
                  #tacDureeBdc` varchar(9) DEFAULT NULL,
                  @tacheclone.tacFacHt = "0"
                  @tacheclone.tacDureeExec = "00:00"
                  @tacheclone.tacPourExec = "0,00%"
                  @tacheclone.tacCout = "000"
                  @tacheclone.tacMarge = "0"
                  @tacheclone.projetId = @projetclone.id.to_s
                  @tacheclone.typetacheId = tache.typetacheId
                  @tacheclone.parametreId = params[:parametre][:id].to_s
                  begin
                      @tacheclone.save
                  rescue => e
                      @erreur = Erreur.new
                      @erreur.dateHeure = @current_time.strftime "%d/%m/%Y %H:%M:%S"
                      @erreur.appli = 'rails - ProjetclonesController - update'
                      @erreur.origine = 'Create Clonetache - tache.id=' + tache.id.to_s
                      @erreur.numLigne = '110'
                      @erreur.message = e.message
                      @erreur.parametreId = params[:parametre][:id].to_s
                      @erreur.save
                      @erreurCreateClone = 1
                  end
              end
          end
      end
      respond_to do |format|
          if @erreurCreateClone == 0
              format.xml { render xml: @projetclone }
          else
              format.xml { render request.format.to_sym => "clpErreurU" }
          end
      end
  end


  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def projet_params
      params.require(:projet).permit!
    end

end
