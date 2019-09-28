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
      # Collecte [sur projets] des 'BdC en Attente' et 'factures impayées' ---------------------------------------
      if @paramun.projets.length > 0
          @paramun.projets.each do |projet|
              if projet.factures.length != 0
                  projet.factures.each do |facture|
                      @selectFactureOK = 0
                      case facture.typeImpr.to_s
                           ## Bon de Commande en Attente -----------------
                          when '10'
                              if (facture.facStatut.to_s != '3Signé/Réglé' && facture.facStatut.to_s != '3Signé' && facture.facStatut.slice(1,14) != 'nonSigné/Réglé')
                                  @selectFactureOK = 1
                              end
                          when '11'
                              if (facture.facStatut.to_s != '3Signé')
                                  @selectFactureOK = 1
                              end
                          ## facture impayée -----------------------
                          when '40', '41', '50', '51'
                              if (facture.facStatut.to_s != '3Réglé' && facture.facStatut.to_s != '3Annulé')
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
      # Collecte [sur projetolds, à l'Exception des projets 'Clos'] des 'BdC en Attente' et 'factures impayées' -----
      @paramunold = Paramunold.find(params[:parametre][:id].to_i)
      if @paramunold.projetolds.length > 0
          @paramunold.projetolds.each do |projetold|
              if projetold.proSituation.to_s != '22'
                  if projetold.factureolds.length != 0
                      projetold.factureolds.each do |factureold|
                          @selectFactureoldOK = 0
                          case factureold.typeImpr.to_s
                               ## Bon de Commande en Attente -----------------
                              when '10'
                                  if (factureold.facStatut.to_s != '3Signé/Réglé' && factureold.facStatut.to_s != '3Signé' && factureold.facStatut.slice(1,14) != 'nonSigné/Réglé')
                                     @selectFactureoldOK = 1
                                  end
                              when '11'
                                  if (factureold.facStatut.to_s != '3Signé')
                                      @selectFactureoldOK = 1
                                  end
                              ## facture impayée -----------------------
                              when '40', '41', '50', '51'
                                  if (factureold.facStatut.to_s != '3Réglé' && factureold.facStatut.to_s != '3Annulé')
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