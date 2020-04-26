class Facture < ApplicationRecord

  include ActiveModel::Serializers::Xml

    #belongs_to :projet, :foreign_key => 'projetId'

end
