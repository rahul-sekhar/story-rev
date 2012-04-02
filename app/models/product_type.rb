class ProductType < ActiveRecord::Base
  has_many :products
  
  validates :name, :length => { :maximum => 100 }, :presence => true, :uniqueness => { :case_sensitive => false }
  
  scope :prioritised, order("priority DESC")
  scope :visible, where("priority > 0")
end
