class TransactionCategory < ActiveRecord::Base
  after_initialize :init
  before_save :check_data
  
  belongs_to :account
  belongs_to :transaction_category
  belongs_to :payment_method
  
  has_one :order
  
  validates :name, :length => { :maximum => 120 }, :presence => true, :uniqueness => { :case_sensitive => false }
  validates :account_id, :presence => true
  
  def init
    self.credit ||= 0
    self.debit ||= 0
  end
  
  def check_data
    self.date = DateTime.now if date.nil?
    self.off_record = transaction_category.off_record if transaction_category.present?
  end
end
