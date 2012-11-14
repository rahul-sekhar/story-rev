class ExtraCost < ActiveRecord::Base
  belongs_to :complete_order, foreign_key: :order_id

  attr_accessible :name, :amount, :expenditure
  after_save :recalculate_order
  after_destroy :recalculate_order
 
  validates :name, presence: true, length: { maximum: 255 }
  validates :amount, presence: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :order, presence: true
  validates :expenditure, presence: true, 
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def order
    complete_order
  end

  def recalculate_order
    order.recalculate
  end
end