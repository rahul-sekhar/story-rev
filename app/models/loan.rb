class Loan < ActiveRecord::Base
  attr_accessible :name, :amount, :short_date, :payment

  attr_reader :payment
  after_save :create_transaction

  validates :name, presence: true, length: { maximum: 200 }
  validates :amount, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :payment, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_blank: true

  strip_attributes

  def payment=(val)
    @payment = val.to_i
    self.amount = amount - payment
  end

  def create_transaction
    if payment.to_i > 0
      trans = Transaction.new(
        debit: payment,
        other_party: name,
      );
      trans.transaction_category = TransactionCategory.find_or_create("Loan repayment")
      trans.date = DateTime.now
      trans.save
    end
  end
end