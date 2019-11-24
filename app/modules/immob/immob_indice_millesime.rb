module ImmobIndiceMillesime
    ## Restitue l'indice correspondant à un Millésime ******************************
    def immob_indice_millesime_trait(millesime)
        case millesime
            when @current_year.to_i
                return 0
            when @current_year.to_i - 1
                return 1    
            when @current_year.to_i - 2
                return 2
            when @current_year.to_i - 3
                return 3    
            when @current_year.to_i - 4
                return 4     
            when @current_year.to_i - 5
                return 5      
            when @current_year.to_i - 6
                return 6
            else
                return 9
        end
    end
end