class Account < ActiveRecord::Base
  extend FindableByName
  
  attr_accessible :name

  has_many :transactions, :dependent => :nullify
  
  validates :name, :length => { :maximum => 120 }, :presence => true, :uniqueness => { :case_sensitive => false }
  
  def balance
    transactions.inject(0){|balance,x| balance + x.credit - x.debit }
  end
end