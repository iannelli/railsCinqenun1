class Tvaimpot < ApplicationRecord
  
    include ActiveModel::Serializers::Xml
    
    has_many :recettes, :foreign_key => 'tvaimpotId'
    
    has_many :depenses, :foreign_key => 'tvaimpotId'
  
end
