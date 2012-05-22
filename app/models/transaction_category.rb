class TransactionCategory < ActiveRecord::Base
  after_initialize :init
  
  has_many :transactions, :dependent => :nullify
  
  validates :name, :length => { :maximum => 120 }, :presence => true, :uniqueness => { :case_sensitive => false }
  
  def init
    self.off_record = false if off_record.nil?
  end
  
  def self.name_is(data)
    where("LOWER(name) = ?", data.downcase)
  end
  
  def self.name_like(data)
    where("LOWER(name) LIKE ?", "%#{SqlHelper::escapeWildcards(data.downcase)}%")
  end
end
