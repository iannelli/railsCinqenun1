class Clientele < ApplicationRecord
  
  include ActiveModel::Serializers::Xml
  
    has_many :contacts, :foreign_key => 'clienteleId'

    #belongs_to :paramun, :foreign_key => 'parametreId'
  
end
