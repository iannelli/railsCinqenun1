class Soustraitant < ApplicationRecord
  include ActiveModel::Serializers::Xml
  
    #belongs_to :paramun, :foreign_key => 'parametreId'
  
end
