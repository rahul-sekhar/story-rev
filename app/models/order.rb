class Order < ActiveRecord::Base
  default_scope -> { where(complete: false) }
  attr_accessible :add_copy, :remove_copy, :empty, :change_number

  has_many :order_copies, dependent: :destroy, validate: true
  has_many :copies, through: :order_copies
  has_many :used_copies, through: :order_copies
  has_many :new_copies, through: :order_copies
  has_one :customer, dependent: :destroy

  validates :total_amount, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :postage_amount, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :complete, inclusion: { in: [true, false] }

  def self.clear_old(silent = false)
    cleared = 0
    Order.where{updated_at < 14.days.ago}.each do |x|
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

  def change_number=(params)
    oc = self.order_copies.find_by_copy_id!(params['copy_id'])
    oc.update_attributes(number: params['number']) if oc
  end

  def cart_amount
    order_copies.inject(0){ |s, x| s + x.price }
  end

  def calculate_amounts
    if customer.delivery_method == 1
      self.postage_amount = order_copies.finalized.inject(30){ |s, x| s + 10 * x.number }
    else
      self.postage_amount = 0
    end

    self.total_amount = order_copies.finalized.inject(0){ |s, x| s + x.price } + postage_amount
  end

  def check_unstocked
    order_copies.each do |x|
      x.final = (x.copy.stock > 0)
      x.save
    end
  end

  def finalize
    raise "Attempted to finalize an order that is already complete" if complete

    customer.step = 4
    raise "Invalid order information" if customer.invalid?

    # Destroy any order copies that were previously shown as being unstocked
    self.order_copies.unfinalized.each{ |x| x.destroy }

    # Check for newly unstocked copies
    check_unstocked

    # Set the stocks for the finalized copies
    self.order_copies.finalized.each{ |x| x.finalize }

    calculate_amounts

    self.complete = true
    self.confirmed_date = DateTime.now
    save
  end
end
