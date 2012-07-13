class Account < ActiveRecord::Base
  has_many :transactions, :dependent => :nullify
  has_many :transfers_from, 
    class_name: "Transfer", 
    foreign_key: "source_account_id"
  has_many :transfers_to, 
    class_name: "Transfer", 
    foreign_key: "target_account_id"
  
  validates :name, :length => { :maximum => 120 }, :presence => true, :uniqueness => { :case_sensitive => false }
  
  def self.name_is(data)
    where("LOWER(name) = ?", data.downcase)
  end
  
  def self.name_like(data)
    where("LOWER(name) LIKE ?", "%#{SqlHelper::escapeWildcards(data.downcase)}%")
  end
  
  def balance
    transactions.inject(0){|balance,x| balance + x.credit - x.debit } +
    transfers_to.inject(0){|balance,x| balance + x.amount } -
    transfers_from.inject(0){|balance,x| balance + x.amount }
  end
end
