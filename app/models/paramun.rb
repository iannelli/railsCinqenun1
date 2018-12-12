class Paramun < ApplicationRecord
  include ActiveModel::Serializers::Xml
  
    has_many :clienteles, :foreign_key => 'parametreId'

    has_many :depenses, :foreign_key => 'parametreId'

    has_many :familletaches, class_name: 'Familletache', :foreign_key => 'parametreId'

    has_many :projets, :foreign_key => 'parametreId'

    has_many :recettes, :foreign_key => 'parametreId'

    has_many :soustraitants, :foreign_key => 'parametreId'

    has_many :typetaches, :class_name => 'Typetache', :foreign_key => 'parametreId'
  
end
