module VerifPresenceDoublon
      ## Vérification de l'absence de "doublon" pour le type d'Imprimé créé
      def verif_presence_doublon_trait
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
end