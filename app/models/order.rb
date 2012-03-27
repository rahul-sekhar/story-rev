class Order < ActiveRecord::Base
  after_initialize :init
  after_validation :change_step_if_invalid
  before_save :remove_unecessary_fields, :refresh_if_incomplete
  
  attr_accessible :next_step, :delivery_method, :pickup_point_id, :other_pickup,
    :payment_method, :name, :email, :phone, :address, :city, :pin_code, :other_info
  
  attr_reader :next_step, :out_of_stock
  attr_writer :out_of_stock
  
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
    elsif attr_invalid?(:name) || attr_invalid?(:email)
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
  
  def refresh_if_incomplete
    if (step < 5 && shopping_cart)
      
      if copies.unstocked.length > 0
        Loggers.store_log "Copies went out of stock during order (##{id}) - Copy ids: #{copies.unstocked.map{|x| x.id}.join(", ")}"
      end
      
      
      self.copies = shopping_cart.copies.stocked
      calculate_total
    end
  end
  
  def calculate_total
    total = 0
    postage = 0
    
    copies.each do |c|
      total += c.price
      if (delivery_method == 1)
        postage += 10
      end
    end
    
    self.total_amount = total + postage
    self.postage_amount = postage
  end
  
  def finalise
    self.out_of_stock = []
    
    copies.each do |c|
      if c.in_stock
        c.set_stock = false
      else
        self.out_of_stock << c
      end
    end
    
    if out_of_stock.length > 0
      Loggers.store_log "Copies went out of stock after order confirmation (##{id}) - Copy ids: #{out_of_stock.map{|x| x.id}.join(", ")}"
    end
    
    out_of_stock.each do |c|
      self.copies.delete(c)
    end
    
    calculate_total
    
    self.shopping_cart.copies = []
    self.shopping_cart_id = nil
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
  
  def delivery_name
    case delivery_method.to_i
    when 1
      "speed post"
    when 2
      "pickup"
    end
  end
  
  def payment_name
    case delivery_method.to_i
    when 1
      "bank transfer"
    when 2
      "cheque"
    end
  end
end
