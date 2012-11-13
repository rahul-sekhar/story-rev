class OrderCopy < ActiveRecord::Base
  self.table_name = :orders_copies

  default_scope -> { includes{copy} }

  after_initialize :init
  after_destroy :recalculate_order, :revert_copy
  after_save :recalculate_order, :change_copy_stock
  
  attr_accessible :copy_id, :number, :ticked
  
  belongs_to :order
  belongs_to :complete_order, foreign_key: :order_id
  belongs_to :copy, readonly: true
  belongs_to :new_copy, foreign_key: :copy_id
  belongs_to :used_copy, foreign_key: :copy_id

  validates :copy, presence: true
  validates :number, numericality: { only_integer: true, greater_than: 0}
  validates :ticked, inclusion: { in: [true, false] }
  validates :final, inclusion: { in: [true, false] }

  scope :stocked, -> { joins{copy}.where{copy.stock > 0} }
  scope :unstocked, -> { joins{copy}.where{copy.stock <= 0} }
  scope :finalized, -> { where(final: true) }
  scope :unfinalized, -> { where(final: false) }

  def init
    @prev_number = new_record? ? 0 : number
  end
  
  def number=(val)
    write_attribute(:number, val.to_i) if copy.new_copy && val.to_i > 0
  end

  def price
    copy.price * number
  end

  def finalize
    raise "Attempting to finalize an order copy with an unstocked copy" if copy.stock <= 0
    raise "Attempting to finalize an order copy with final set to false" if final != true
    if used_copy.present?
      used_copy.stock = used_copy.stock - number
      used_copy.save
    elsif new_copy.present?
      new_copy.stock = new_copy.stock - number
      new_copy.save
    end
  end

  def recalculate_order
    complete_order.recalculate if final && complete_order.present?
  end

  def change_copy_stock
    if final && complete_order.present? && number != @prev_number
      c = new_copy.present? ? new_copy : used_copy
      c.stock = c.stock - (number - @prev_number)
      c.save
      @prev_number = number
    end
  end

  def revert_copy
    if final && complete_order.present?
      c = new_copy.present? ? new_copy : used_copy
      c.stock = c.stock + number
      c.save
    end
  end
end
