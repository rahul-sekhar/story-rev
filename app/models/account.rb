class Account < ActiveRecord::Base
  extend FindableByName

  attr_writer :payment
  attr_accessible :name, :share, :payment

  before_save :check_transaction_names
  after_save :create_payment_transaction

  validate :check_sum_of_shares

  has_many :account_profit_shares, dependent: :destroy
  has_many :transactions, dependent: :destroy

  validates :name, length: { maximum: 120 }, presence: true, uniqueness: { case_sensitive: false }
  validates :share, numericality: { 
    only_integer: true, 
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100
  }

  strip_attributes

  def amount_due
    total_profit - total_payments
  end

  def total_profit
    account_profit_shares.inject(0){ |s, x| s + x.amount }
  end

  def total_payments
    transactions.inject(0){ |s, x| s + x.debit }
  end

  def check_sum_of_shares
    if sum_of_other_shares + share.to_i > 100
      errors.add(:share, "cannot exceed 100% in total") 
    end
  end

  def sum_of_other_shares
    Account.where{id != my{self.id}}.inject(0){ |s, x| s + x.share }
  end

  private

  def check_transaction_names
    transactions.where{other_party != my{name}}.each do |x|
      x.other_party = name
      x.save
    end
  end

  def create_payment_transaction
    if @payment.to_i > 0
      trans = transactions.build
      trans.debit = @payment.to_i
      trans.other_party = name
      trans.transaction_category = TransactionCategory.find_or_create("Profit payment")
      trans.save
    end
  end
end
