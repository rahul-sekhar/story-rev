class PaymentMethod < ActiveRecord::Base
  extend FindableByName
  
  attr_accessible :name 
  
  has_many :customers, dependent: :restrict
  has_many :transactions, dependent: :restrict
  
  validates :name, length: { maximum: 120 }, 
    presence: true, 
    uniqueness: { case_sensitive: false }

  strip_attributes
end
