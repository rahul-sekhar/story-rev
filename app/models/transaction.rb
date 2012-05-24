class Transaction < ActiveRecord::Base
  after_initialize :init
  before_save :check_data
  
  belongs_to :account
  belongs_to :transaction_category
  belongs_to :payment_method
  
  has_one :order
  has_one :postage_order, :class_name => "Order", :foreign_key => :postage_transaction_id
  
  validates :account_id, :presence => true
  
  def init
    self.credit ||= 0
    self.debit ||= 0
  end
  
  def check_data
    self.date = DateTime.now if date.nil?
    self.off_record = transaction_category.off_record if transaction_category.present?
    return nil
  end
  
  def formatted_credit
    (credit && credit > 0) ? RupeeHelper.to_rupee(credit) : '-'
  end
  
  def formatted_debit
    (debit && debit > 0) ? RupeeHelper.to_rupee(debit) : '-'
  end
  
  # Format date as in 'Nov 19, 2012'
  def formatted_date
    date.strftime("%b %e, %Y")
  end
  
  def timestamp
    date.to_i
  end
  
  def transaction_category_name
    transaction_category && transaction_category.name
  end
  
  def payment_method_name
    payment_method && payment_method.name
  end
  
  def account_name
    account && account.name
  end
end
