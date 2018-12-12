class Projetold < ApplicationRecord
  establish_connection "#{Rails.env}_sec".to_sym
  include ActiveModel::Serializers::Xml

    #belongs_to :paramunold, :foreign_key => 'parametreoldId'

    has_many :tacheolds, class_name: 'Tacheold', :foreign_key => 'projetoldId'
    has_many :factureolds, :foreign_key => 'projetoldId'

end
