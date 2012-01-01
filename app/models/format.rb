class Format < ActiveRecord::Base
  has_many :editions, :dependent => :nullify
  
  validates :name, :length => { :maximum => 100 }, :presence => true, :uniqueness => { :case_sensitive => false }
end
