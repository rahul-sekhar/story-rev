class Account < ActiveRecord::Base
  has_many :transactions, :dependent => :nullify
  
  validates :name, :length => { :maximum => 120 }, :presence => true, :uniqueness => { :case_sensitive => false }
  
  def self.name_is(data)
    where("LOWER(name) = ?", data.downcase)
  end
  
  def self.name_like(data)
    where("LOWER(name) LIKE ?", "%#{SqlHelper::escapeWildcards(data.downcase)}%")
  end
end
