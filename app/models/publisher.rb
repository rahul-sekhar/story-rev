class Publisher < ActiveRecord::Base
  has_many :products, :dependent => :nullify
  
  validates :name, :length => { :maximum => 150 }, :presence => true
end
