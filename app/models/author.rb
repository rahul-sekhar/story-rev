class Author < ActiveRecord::Base
  include Person
  
  attr_accessible :name, :priority
  attr_writer :name
  
  before_validation :convert_name
  
  has_many :books, :dependent => :destroy
  
  validates :name, :length => { :maximum => 150 }, :presence => true
  
  scope :prioritised, order("priority DESC, last_name, first_name")
  scope :visible, where("priority > 0")
end
