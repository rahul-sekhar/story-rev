class Genre < ActiveRecord::Base
  has_and_belongs_to_many :products
  
  validates :name, :length => { :maximum => 100 }, :presence => true
end
