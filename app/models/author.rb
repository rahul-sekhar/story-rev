class Author < ActiveRecord::Base
  include Person
  
  attr_writer :full_name
  
  before_validation :convert_full_name
  
  has_many :products, :dependent => :destroy
  
  validates :full_name, :length => { :maximum => 150 }, :presence => true
end
