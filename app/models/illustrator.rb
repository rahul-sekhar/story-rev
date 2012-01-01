class Illustrator < ActiveRecord::Base
  include Person
  
  attr_writer :full_name
  
  has_many :products, :dependent => :nullify
  
  validates :full_name, :length => { :maximum => 150 }, :presence => true
  
  before_save :convert_full_name
  
end
