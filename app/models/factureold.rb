class Factureold < ApplicationRecord
  establish_connection "#{Rails.env}_sec".to_sym
  include ActiveModel::Serializers::Xml

    #belongs_to :projetold, :foreign_key => 'projetoldId'

end
