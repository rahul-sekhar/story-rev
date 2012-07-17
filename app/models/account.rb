class Account < ActiveRecord::Base
  extend FindableByName
  
  attr_accessible :name

  has_many :transactions, :dependent => :nullify
  has_many :transfers_from, 
    class_name: "Transfer", 
    foreign_key: "source_account_id"
  has_many :transfers_to, 
    class_name: "Transfer", 
    foreign_key: "target_account_id"
  has_many :orders
  
  validates :name, :length => { :maximum => 120 }, :presence => true, :uniqueness => { :case_sensitive => false }

  scope :default_order, -> { order("id=#{ConfigData.access.cash_account_id} DESC, id=#{ConfigData.access.default_account_id} DESC") }
  
  def balance
    transactions.inject(0){|balance,x| balance + x.credit - x.debit } +
    transfers_to.inject(0){|balance,x| balance + x.amount } -
    transfers_from.inject(0){|balance,x| balance + x.amount }
  end
end
