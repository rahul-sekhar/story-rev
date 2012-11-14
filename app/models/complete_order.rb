class CompleteOrder < ActiveRecord::Base
  self.table_name = :orders
  
  default_scope -> { where(complete: true) }

  before_create :set_confirmed_date

  has_many :order_copies, dependent: :destroy, validate: true, conditions: { final: true }, foreign_key: :order_id
  has_many :unfinalized_order_copies, dependent: :destroy, validate: true, conditions: { final: false }, foreign_key: :order_id, class_name: OrderCopy
  has_many :copies, through: :order_copies
  has_many :used_copies, through: :order_copies
  has_many :new_copies, through: :order_copies
  has_one :customer, dependent: :destroy, foreign_key: :order_id
  has_many :extra_costs, dependent: :destroy, foreign_key: :order_id

  validates :total_amount, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :postage_amount, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :complete, inclusion: { in: [true, false] }

  scope :finalized, -> { where{(confirmed_date != nil) & (paid_date != nil) & (posted_date != nil) & (packaged_date != nil)} }
  scope :unfinalized, -> { where{(confirmed_date == nil) | (paid_date == nil) | (posted_date == nil) | (packaged_date == nil)} }
  scope :order_by_confirmed, order{ confirmed_date.desc }

  def add_copy=(copy_id)
    self.order_copies.create(copy_id: copy_id) unless copy_ids.include? copy_id.to_i
  end

  def remove_copy=(copy_id)
    self.order_copies.where(copy_id: copy_id).each { |oc| oc.destroy }
  end

  def recalculate
    order_copies.reload
    extra_costs.reload
    calculate_amounts
    save
  end

  def number_of_copies
    order_copies.inject(0){ |s, x| s + x.number }
  end

  def set_confirmed_date
    self.confirmed = true
  end

  # Set the confirmed, paid, packed, posted dates when the properties are set as boolean values
  def confirmed=(val)
    self.confirmed_date = (val && val != "false") ? confirmed_date || DateTime.now : nil
  end
  
  def paid=(val)
    self.paid_date = (val && val != "false") ? paid_date || DateTime.now : nil
  end
  
  def packaged=(val)
    self.packaged_date = (val && val != "false") ? packaged_date || DateTime.now : nil
  end
  
  def posted=(val)
    self.posted_date = (val && val != "false") ? posted_date || DateTime.now : nil
  end
  

  # Return the dates as boolean values depending on whether they exist or not
  def confirmed
    confirmed_date.present?
  end
  
  def paid
    paid_date.present?
  end
  
  def posted
    posted_date.present?
  end
  
  def packaged
    packaged_date.present?
  end

  private

  def calculate_amounts
    if customer.delivery_method == 1
      self.postage_amount = order_copies.inject(0){ |s, x| s + 10 * x.number }
      self.postage_amount += 10 if postage_amount > 0
    else
      self.postage_amount = 0
    end

    self.total_amount = order_copies.inject(0){ |s, x| s + x.price } + postage_amount
    self.total_amount += extra_costs.inject(0){ |s, x| s + x.amount }
  end
end