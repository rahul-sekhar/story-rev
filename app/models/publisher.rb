class Publisher < ActiveRecord::Base
  has_many :editions, :dependent => :nullify
  has_many :products, :dependent => :nullify
  
  validates :name, :length => { :maximum => 150 }, :presence => true
  
  def self.name_like(data)
    where("LOWER(name) like ?", "%#{SqlHelper::escapeWildcards(data.downcase)}%")
  end
  
  def self.name_is(data)
    where("LOWER(name) = ?", data.downcase)
  end
end
