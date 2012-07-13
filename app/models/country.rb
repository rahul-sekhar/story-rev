class Country < ActiveRecord::Base
  extend FindableByName
  
	attr_accessible :name
  
  has_many :books, :dependent => :nullify
  
  validates :name, 
    length: { maximum: 100 }, 
    presence: true, 
    uniqueness: { case_sensitive: false }

  strip_attributes
end
