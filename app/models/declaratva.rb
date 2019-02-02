class Declaratva < ApplicationRecord
    
    include ActiveModel::Serializers::Xml
    
    has_many :depenses, :foreign_key => 'declaTvaId'
    
    has_many :recettes, :foreign_key => 'declaTvaId'
    
    
    
end
