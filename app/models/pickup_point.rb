class PickupPoint < ActiveRecord::Base
  attr_accessible :name

  has_many :orders
  
  validates :name, 
    length: { maximum: 255 },
    presence: true,
    uniqueness: { case_sensitive: false }

  strip_attributes
  
end
