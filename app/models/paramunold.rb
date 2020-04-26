class Paramunold < ApplicationRecord
  establish_connection "#{Rails.env}_sec".to_sym
  include ActiveModel::Serializers::Xml

    has_many :projetolds, :foreign_key => 'parametreoldId'

    has_many :depenseolds, :foreign_key => 'parametreoldId'

    has_many :immobolds, :foreign_key => 'parametreoldId'

    has_many :recetteolds, :foreign_key => 'parametreoldId' 

end
