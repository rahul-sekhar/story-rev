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
  
  def short_date
    date.strftime("%d-%m-%Y")
  end
  
  def short_date=(val)
    self.date = DateTime.strptime(val, "%d-%m-%Y")
  end
  
  def order_url
    return order.present? ? order.get_url : nil
  end
  
  def get_hash
    {
      :id => id,
      :formatted_date => formatted_date,
      :short_date => short_date,
      :timestamp => timestamp,
      :transaction_category_name => transaction_category_name,
      :transaction_category_id => transaction_category_id,
      :other_party => other_party,
      :payment_method_name => payment_method_name,
      :payment_method_id => payment_method_id,
      :account_name => account_name,
      :account_id => account_id,
      :notes => notes,
      :credit => credit,
      :formatted_credit => formatted_credit,
      :debit => debit,
      :formatted_debit => formatted_debit,
      :order_url => order_url
    }
  end
end
