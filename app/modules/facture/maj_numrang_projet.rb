module MajNumrangProjet
    # Mise à Jour de proNumRang du Projet correspondant ------
    def maj_numrang_projet_trait
        case @facture.typeImpr.to_s #
            when '10'
                @proNumRangArray[0] = @facture.id
                numRang = @proNumRangArray[1].to_i
                numRang += 1
                @proNumRangArray[1] = numRang
            when '11'
                @proNumRangArray[2] = @facture.id
                numRang = @proNumRangArray[3].to_i
                numRang += 1
                @proNumRangArray[3] = numRang
            when '40', '50'
                numRang = @proNumRangArray[1].to_i
                numRang += 1
                @proNumRangArray[1] = numRang
            when '41', '51'
                numRang = @proNumRangArray[3].to_i
                numRang += 1
                @proNumRangArray[3] = numRang
            when '60'
                numRang = @proNumRangArray[1].to_i
                numRang -= 1
                @proNumRangArray[1] = numRang
            when '61'
                numRang = @proNumRangArray[3].to_i
                numRang -= 1
                @proNumRangArray[3] = numRang
        end
    end
end