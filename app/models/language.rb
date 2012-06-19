class Language < ActiveRecord::Base
  attr_accessible :name
  
  has_many :editions, :dependent => :nullify
  
  validates :name, :length => { :maximum => 100 }, :presence => true, :uniqueness => { :case_sensitive => false }
  
  def self.name_is(data)
    where("LOWER(name) = ?", data.downcase)
  end
  
  def self.name_like(data)
    where("LOWER(name) LIKE ?", "%#{SqlHelper::escapeWildcards(data.downcase)}%")
  end
end
