class AccountProfitShare < ActiveRecord::Base
  belongs_to :account
  belongs_to :complete_order, foreign_key: :order_id

  validates :account, presence: true
  validates :complete_order, presence: true

  validates :amount, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end