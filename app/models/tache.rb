class Tache < ApplicationRecord
  
  include ActiveModel::Serializers::Xml
  
    #belongs_to :projet, :foreign_key => 'projetId'
    #belongs_to :typetache, :foreign_key => 'typetacheId'
  
end
