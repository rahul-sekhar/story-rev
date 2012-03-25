class PickupPoint < ActiveRecord::Base
  has_many :orders
  
  validates :name, :length => { :maximum => 255 }, :presence => true
  
end
