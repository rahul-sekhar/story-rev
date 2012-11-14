class TransactionCategory < ActiveRecord::Base
  extend FindableByName
  
  attr_accessible :name
  
  has_many :transactions, dependent: :nullify
  
  validates :name, length: maximum: 120, presence: true, uniqueness: { case_sensitive: false }
end
