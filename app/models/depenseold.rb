class Depenseold < ApplicationRecord
  establish_connection "#{Rails.env}_sec".to_sym
  include ActiveModel::Serializers::Xml

    #belongs_to :paramunold, :foreign_key => 'parametreoldId'
    
end
