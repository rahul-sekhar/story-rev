class ExtraCost < ActiveRecord::Base
  after_initialize :init

  belongs_to :order

  attr_accessible :name, :amount
  
  validates :name, presence: true, length: { maximum: 255 }
  validates :amount, presence: true, numericality: { only_integer: true }

  def init
    amount ||= 0
  end

  def formatted_amount
    RupeeHelper.to_rupee(amount || 0)
  end

  def get_hash
    {
      id: id,
      name: name,
      amount: amount,
      formatted_amount: formatted_amount,
      total_amount: order.formatted_total_amount,
      postage_amount: order.formatted_postage_amount
    }
  end
end