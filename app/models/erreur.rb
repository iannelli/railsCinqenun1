class Erreur < ApplicationRecord
  establish_connection "#{Rails.env}_tro".to_sym
  include ActiveModel::Serializers::Xml  
  
end
