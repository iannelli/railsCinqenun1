class Lignetvaold < ApplicationRecord
  
      establish_connection "#{Rails.env}_sec".to_sym
      include ActiveModel::Serializers::Xml
  
end