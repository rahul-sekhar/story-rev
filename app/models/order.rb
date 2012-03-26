class Order < ActiveRecord::Base
  after_initialize :init
  after_validation :change_step_if_invalid
  before_save :remove_unecessary_fields
  
  attr_accessible :next_step, :delivery_method, :pickup_point_id, :other_pickup,
    :payment_method, :name, :email, :phone, :address, :city, :pin_code, :more_info
  
  attr_reader :next_step
  
  has_and_belongs_to_many :copies, :join_table => :orders_copies, :uniq => true
  
  belongs_to :pickup_point
  belongs_to :shopping_cart
  
  # Delivery_method (step 1)
  # 1 - Speed Post
  # 2 - Pickup Point
  validates :delivery_method, :inclusion => { :in => [1,2], :message => "must be chosen" }, :presence => true
  validates :pickup_point_id, :numericality => { :only_integer => true }, :if => :pickup_delivery?
  
  # Delivery_method (step 2)
  # 1 - Online bank transfer
  # 2 - Cheque
  validates :payment_method, :inclusion => { :in => [1,2], :message => "must be chosen" }, :presence => true, :unless => :below_step_2?
  
  #Details (step 3)
  validates :name, :presence => :true, :unless => :below_step_3?
  validates :email, :presence => :true, :unless => :below_step_3?
  
  validates :address, :presence => :true, :if => :post_delivery?, :unless => :below_step_3?
  validates :city, :presence => :true, :if => :post_delivery?, :unless => :below_step_3?
  validates :pin_code, :presence => :true, :if => :post_delivery?, :unless => :below_step_3?
  
  scope :complete, where(:step => 5)
  
  
  def init
    self.step ||= 1
    self.delivery_method ||= 1
    self.payment_method ||= 1
  end
  
  def change_step_if_invalid
    return if errors.size == 0
    
    valid_step = step
    
    if attr_invalid?(:delivery_method) || attr_invalid?(:pickup_point_id)
      valid_step = 1
    elsif attr_invalid?(:payment_method)
      valid_step = 2
    elsif attr_invalid?(:name) || attr_invalid?(:email) || attr_invalid?(:address) || attr_invalid?(:city) || attr_invalid?(:pin_code)
      valid_step = 3
    elsif attr_invalid?(:next_step)
      valid_step = 1
    end
    
    self.step = [step, valid_step].min
  end
  
  def attr_invalid?(attr)
    errors[attr].present?
  end
  
  
  def next_step=(n)
    self.step = n.to_i
    
    calculate_total if (n.to_i == 4)
  end
  
  def first_step?
    step == 1
  end
  
  def below_step_2?
    step <= 2
  end
  
  def below_step_3?
    step <= 3
  end
  
  def post_delivery?
    delivery_method == 1
  end
  
  def pickup_delivery?
    delivery_method == 2
  end
  
  def complete?
    step == 5
  end
  
  def calculate_total
    total = 0
    postage = 0
    
    shopping_cart.copies.stocked.each do |c|
      total += c.price
      if (delivery_method == 1)
        postage += 10
      end
    end
    
    self.total_amount = total + postage
    self.postage_amount = postage
  end
  
  def finalise
    calculate_total
    
    shopping_cart.copies.stocked.each do |c|
      c.set_stock = false
    end
    
    self.copies = shopping_cart.copies
    self.shopping_cart.destroy
    save
  end
  
  def remove_unecessary_fields
    # Remove pickup point if it is unrequired
    if (delivery_method != 2)
      self.pickup_point_id = nil
    end
    
    # Remove other pickup text if it is unrequired
    if (other_pickup.present? && (delivery_method != 2 || pickup_point_id != 0))
      self.other_pickup = nil
    end
  end
end
