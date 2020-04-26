class Typetache < ApplicationRecord

  include ActiveModel::Serializers::Xml

    #belongs_to :paramun, :foreign_key => 'parametreId'

    has_many :taches, class_name: 'Tache', :foreign_key => 'typetacheId'

end
