class Illustrator < ActiveRecord::Base
  include Person
  attr_accessible :name, :priority
  
  attr_writer :name
  
  has_many :books, :dependent => :nullify
  
  validates :name, :length => { :maximum => 150 }, :presence => true
  
  before_save :convert_name
  
  scope :prioritised, order("priority DESC, last_name, first_name")
  scope :visible, where("priority > 0")
end
