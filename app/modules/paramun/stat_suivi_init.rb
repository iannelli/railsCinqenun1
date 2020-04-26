module StatSuiviInit
    # Initialisation des Arrays
    def stat_suivi_init_trait
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
        @sixDernierMoisArray[0] = @aaaa.to_s + "%02d" % @mm.to_i
        m=1
        while m<6
            @mm = @mm.to_i - 1
            if @mm.to_i == 0
                @mm = 12
                @aaaa = @aaaa.to_i - 1
            end
            @sixDernierMoisArray[m] = @aaaa.to_s + "%02d" % @mm.to_i
            m += 1
        end
        ## Initialisation des 3 Arrays -----
        m=0
        rd=0
        f=0
        while m<6
            @statRecetteAccueilArray[rd] = @sixDernierMoisArray[m]
            @statDepenseAccueilArray[rd] = @sixDernierMoisArray[m]
            @statFactureAccueilArray[f] = @sixDernierMoisArray[m]
            rd += 1
            f += 1
            @statRecetteAccueilArray[rd] = '0'
            @statDepenseAccueilArray[rd] = '0'
            @statFactureAccueilArray[f] = '0'
            f += 1
            @statFactureAccueilArray[f] = '0'
            rd += 1
            f += 1
            m += 1
        end

        @statFactureAccueilArray[f] = 'antérieur'
        @statFactureAccueilArray[f+1] = '0'
        @statFactureAccueilArray[f+2] = '0'
    end
end