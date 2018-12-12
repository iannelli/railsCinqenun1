class SuivisController < ApplicationController

  # TEST de Connexion *******************
  before_action :authenticate_rights
  def authenticate_rights
      dateConnex = params[:parametre][:parDateConnex]
      @paramun = Paramun.find(params[:parametre][:id].to_i)

      if dateConnex.to_i > @paramun.parDateConnex.to_i
          respond_to do |format|
              format.xml { render request.format.to_sym => "suiErreurS" }
          end
      end
  end


  # GET /suivis ****** CHARGEMENT ************************
  # GET /suivis.xml
  def index
      @suiviArray = []
      @suiviString = ""
      time = Time.new
      @annee = time.year
      # Traitement de Collecte des facture de Projet ---------------------------------------
      if @paramun.projets.length > 0
          @paramun.projets.each do |projet|
              if projet.factures.length != 0
                  projet.factures.each do |facture|
                      @selectFactureOK = 0
                      if (facture.typeImpr.to_s == '10' && facture.facAcomTaux.to_i > 0)
                          if ( (facture.facStatut == '3Signé/Réglé' || facture.facStatut == '0nonSigné/Réglé' ||
                              facture.facStatut == '1nonSigné/Réglé' || facture.facStatut == '2nonSigné/Réglé') &&
                              facture.facDateReception.slice(6,4) == @annee.to_s )
                              @selectFactureOK = 1
                          end
                          if (facture.facStatut == '0nonSigné/nonRéglé' || facture.facStatut == '0Signé/nonRéglé' ||
                              facture.facStatut == '1nonSigné/nonRéglé' || facture.facStatut == '1Signé/nonRéglé' ||
                              facture.facStatut == '2nonSigné/nonRéglé' || facture.facStatut == '2Signé/nonRéglé')
                              @selectFactureOK = 1
                          end
                      end
                      if ( (facture.typeImpr.to_s == '10' || facture.typeImpr.to_s == '11')  && facture.facAcomTaux.to_i == 0)
                          if (facture.facStatut == '0nonSigné' || facture.facStatut == '1nonSigné' || facture.facStatut == '2nonSigné')
                              @selectFactureOK = 1
                          end
                      end
                      if (facture.typeImpr.to_s == '40' || facture.typeImpr.to_s == '41' ||
                          facture.typeImpr.to_s == '50' || facture.typeImpr.to_s == '51')
                          if (facture.facStatut == '3Réglé' && facture.facDateReception.slice(6,4) == @annee.to_s)
                              @selectFactureOK = 1
                          end
                          if (facture.facStatut == '0nonRéglé' || facture.facStatut == '1nonRéglé' || facture.facStatut == '2nonRéglé')
                              @selectFactureOK = 1
                          end
                      end
                      if (facture.typeImpr.to_s == '60' || facture.typeImpr.to_s == '61')
                          if (facture.facStatut == '3Validé' && facture.facDateReception.slice(6,4) == @annee.to_s)
                              @selectFactureOK = 1
                          end
                          if (facture.facStatut == '0enAttente' || facture.facStatut == '1enAttente' || facture.facStatut == '2enAttente')
                              @selectFactureOK = 1
                          end
                      end
                      if @selectFactureOK == 1
                          @suiviArray << facture.id.to_s
                          @suiviArray << facture.typeImpr.to_s
                          @suiviArray << facture.facRef.to_s
                          @suiviArray << facture.facDateEmis.to_s
                          @suiviArray << facture.facDateReception.to_s
                          @suiviArray << facture.facStatut.to_s
                          @suiviArray << facture.facDateLimite.to_s
                          @suiviArray << facture.facMontHt.to_s
                          @suiviArray << facture.facMontTva.to_s
                          @suiviArray << facture.facMontTtc.to_s
                          @suiviArray << facture.facAcomMont.to_s
                          @suiviArray << facture.facTotalDu.to_s
                          @suiviArray << facture.facReglMont.to_s
                          @suiviArray << projet.id.to_s
                          @suiviArray << projet.proSituation.to_s
                          @suiviArray << projet.proLib.to_s
                          @suiviArray << projet.proCliRaisonFacture.to_s
                      end
                  end
              end
          end         
      end
      # Traitement de Collecte des factureold de Projetold ---------------------------------------
      @paramunold = Paramunold.find(params[:parametre][:id].to_i)
      if @paramunold.projetolds.length > 0
          @paramunold.projetolds.each do |projetold|
              if projetold.factureolds.length != 0
                  projetold.factureolds.each do |factureold|
                      @selectFactureoldOK = 0
                      if (factureold.typeImpr.to_s == '10' && factureold.facAcomTaux.to_i > 0)
                          if ( (factureold.facStatut == '3Signé/Réglé' || factureold.facStatut == '0nonSigné/Réglé' ||
                              factureold.facStatut == '1nonSigné/Réglé' || factureold.facStatut == '2nonSigné/Réglé') &&
                              factureold.facDateReception.slice(6,4) == @annee.to_s )
                              @selectFactureoldOK = 1
                          end
                          if (factureold.facStatut == '0nonSigné/nonRéglé' || factureold.facStatut == '0Signé/nonRéglé' ||
                              factureold.facStatut == '1nonSigné/nonRéglé' || factureold.facStatut == '1Signé/nonRéglé' ||
                              factureold.facStatut == '2nonSigné/nonRéglé' || factureold.facStatut == '2Signé/nonRéglé')
                              @selectFactureoldOK = 1
                          end
                      end
                      if ( (factureold.typeImpr.to_s == '10' || factureold.typeImpr.to_s == '11')  && factureold.facAcomTaux.to_i == 0)
                          if (factureold.facStatut == '0nonSigné' || factureold.facStatut == '1nonSigné' || factureold.facStatut == '2nonSigné')
                              @selectFactureoldOK = 1
                          end
                      end
                      if (factureold.typeImpr.to_s == '40' || factureold.typeImpr.to_s == '41' ||
                          factureold.typeImpr.to_s == '50' || factureold.typeImpr.to_s == '51')
                          if (factureold.facStatut == '3Réglé' && factureold.facDateReception.slice(6,4) == @annee.to_s)
                              @selectFactureoldOK = 1
                          end
                          if (factureold.facStatut == '0nonRéglé' || factureold.facStatut == '1nonRéglé' || factureold.facStatut == '2nonRéglé')
                              @selectFactureoldOK = 1
                          end
                      end
                      if (factureold.typeImpr.to_s == '60' || factureold.typeImpr.to_s == '61')
                          if (factureold.facStatut == '3Validé' && factureold.facDateReception.slice(6,4) == @annee.to_s)
                              @selectFactureOK = 1
                          end
                          if (factureold.facStatut == '0enAttente' || factureold.facStatut == '1enAttente' || factureold.facStatut == '2enAttente')
                              @selectFactureoldOK = 1
                          end
                      end
                      if @selectFactureoldOK == 1
                          @suiviArray << factureold.id.to_s
                          @suiviArray << factureold.typeImpr.to_s
                          @suiviArray << factureold.facRef.to_s
                          @suiviArray << factureold.facDateEmis.to_s
                          @suiviArray << factureold.facDateReception.to_s
                          @suiviArray << factureold.facStatut.to_s
                          @suiviArray << factureold.facDateLimite.to_s
                          @suiviArray << factureold.facMontHt.to_s
                          @suiviArray << factureold.facMontTva.to_s
                          @suiviArray << factureold.facMontTtc.to_s
                          @suiviArray << factureold.facAcomMont.to_s
                          @suiviArray << factureold.facTotalDu.to_s
                          @suiviArray << factureold.facReglMont.to_s
                          @suiviArray << projetold.id.to_s
                          @suiviArray << projetold.proSituation.to_s
                          @suiviArray << projetold.proLib.to_s
                          @suiviArray << projetold.proCliRaisonFacture.to_s
                      end
                  end
              end
          end         
      end
      # Fin Collecte ------------------------------------------
      if @suiviArray.length != 0
          @suiviString = @suiviArray.join('|')
      end
      respond_to do |format|
          if @suiviString.length == 0
               format.xml { render request.format.to_sym => "suiErreurA" } ## Aucune Facture
          else
               format.xml { render request.format.to_sym => @suiviString }
          end
      end     
  end
end