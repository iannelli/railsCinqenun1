class Contact < ApplicationRecord
  
  include ActiveModel::Serializers::Xml
  
    #belongs_to :clientele, :foreign_key => 'clienteleId'
  
end
