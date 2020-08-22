module ParamDepassFranchise
 ## Examen des Conditions de Dépassement de la Franchise TVA -----------
    def param_depass_franchise_trait
        @parDepassArray = @paramun.parDepass.split(",")
        if @statut == 'I' ## Statut Initial
            if @parDepassArray[0].to_s != 'neant'
                if @parDepassArray[1].to_s == 'v'
                    @anMoisDepass = @parDepassArray[0]
                    @depassOK = 1
                else 
                    if @parDepassArray[1].to_i > 0
                        @anMoisDepass = @parDepassArray[0]
                        @depassOK = 1
                    end
                end
            end
        else ## Statut Modifié  
            if @parDepassArray[2].to_s != 'neant'
                if @parDepassArray[3].to_s == 'v'
                    @anMoisDepass = @parDepassArray[2]
                    @depassOK = 1
                else 
                    if @parDepassArray[3].to_i > 0
                         @anMoisDepass = @parDepassArray[2]
                         @depassOK = 1
                    end
                end
            end  
        end
    end
end