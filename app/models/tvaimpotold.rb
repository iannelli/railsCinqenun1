class Tvaimpotold < ApplicationRecord
  
    establish_connection "#{Rails.env}_sec".to_sym
    include ActiveModel::Serializers::Xml
    
    has_many :depenseolds, :foreign_key => 'tvaimpotoldId'

    has_many :recetteolds, :foreign_key => 'tvaimpotoldId'
    
  
end
