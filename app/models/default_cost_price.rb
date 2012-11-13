class DefaultCostPrice < ActiveRecord::Base
  belongs_to :book_type
  belongs_to :format

  validates :book_type, presence: true
  validates :format, presence: true
  validates :cost_price, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }
  validates :format_id, uniqueness: { scope: :book_type_id }

  delegate :name, to: :format, prefix: true
  delegate :name, to: :book_type, prefix: true
end