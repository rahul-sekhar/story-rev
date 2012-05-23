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
end
