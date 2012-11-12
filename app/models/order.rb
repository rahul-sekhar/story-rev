class Order < ActiveRecord::Base
  attr_accessible :add_copy, :remove_copy, :empty

  has_many :order_copies, dependent: :destroy, validate: true
  has_many :copies, through: :order_copies
  has_many :used_copies, through: :order_copies
  has_many :new_copies, through: :order_copies

  has_one :customer, dependent: :destroy

  scope :incomplete, where(final: false)

  def self.clear_old(silent = false)
    cleared = 0
    Order.incomplete.where{updated_at < 14.days.ago}.each do |x|
      x.destroy
      cleared += 1
    end
    
    puts "Cleared #{cleared} orders" unless silent
  end

  def number_of_items
    copies.length
  end

  def add_copy=(copy_id)
    self.order_copies.create(copy_id: copy_id) unless copy_ids.include? copy_id.to_i
  end

  def remove_copy=(copy_id)
    self.order_copies.where(copy_id: copy_id).each { |oc| oc.destroy }
  end

  def empty=(val)
    self.order_copies.clear if val
  end

  def cart_amount
    order_copies.inject(0){ |s, x| s + x.price }
  end

  def calculate_amounts
    self.total_amount = order_copies.stocked.inject(0){ |s, x| s + x.price }
    
    if customer.delivery_method == 1
      self.postage_amount = order_copies.stocked.inject(10){ |s, x| s + 10 * x.number } 
      self.total_amount += postage_amount
    else
      self.postage_amount = 0
    end
  end
end
