class Loan < ActiveRecord::Base
  attr_accessible :name, :amount, :short_date, :payment

  attr_reader :payment

  validates :name, presence: true, length: { maximum: 200 }
  validates :amount, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :payment, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_blank: true

  strip_attributes

  def payment=(val)
    @payment = val
    self.amount = amount - payment
  end
end