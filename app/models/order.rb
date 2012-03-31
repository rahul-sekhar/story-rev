class Order < ActiveRecord::Base
  after_initialize :init
  after_validation :change_step_if_invalid
  before_save :remove_unecessary_fields, :refresh_if_incomplete, :calculate_total
  
  attr_accessible :next_step, :delivery_method, :pickup_point_id, :other_pickup,
    :payment_method, :name, :email, :phone, :address, :city, :pin_code, :other_info,
    :confirmed, :paid, :packaged, :posted
  
  attr_reader :next_step, :out_of_stock
  attr_writer :out_of_stock
  
  has_many :order_copies, :dependent => :destroy, :include => :copy
  has_many :copies, :through => :order_copies, :as => :copy
  
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
    
    self.confirmed = false if confirmed.nil?
    self.paid = false if paid.nil?
    self.packaged = false if packaged.nil?
    self.posted = false if posted.nil?
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
  
  def number_of_copies
    order_copies.map{|x| x.number}.inject(:+)
  end
  
  def refresh_if_incomplete
    if (step < 5 && shopping_cart)
      
      if copies.unstocked.length > 0
        Loggers.store_log "Copies went out of stock during order (##{id}) - Copy ids: #{copies.unstocked.map{|x| x.id}.join(", ")}"
      end
      
      self.order_copies = []
      shopping_cart.shopping_cart_copies.stocked.each do |scc|
        oc = self.order_copies.build
        oc.copy = scc.copy
        oc.number = scc.number
        oc.save
      end
    end
  end
  
  def calculate_total
    total = 0
    postage = 0
    
    order_copies.each do |oc|
      total += oc.price
      if (delivery_method == 1)
        postage += (10 * oc.number)
      end
    end
    
    postage += 10 if postage > 0 # First book shipping charge is 20
    
    self.total_amount = total + postage
    self.postage_amount = postage
  end
  
  def finalise
    self.out_of_stock = []
    
    order_copies.each do |oc|
      if oc.copy.new_copy
        oc.copy.number -= oc.number
        oc.copy.save
      else
        if oc.copy.in_stock
          oc.copy.set_stock = false
        else
          self.out_of_stock << oc
        end
      end
    end
    
    if out_of_stock.length > 0
      Loggers.store_log "Copies went out of stock after order confirmation (##{id}) - Copy ids: #{out_of_stock.map{|x| x.id}.join(", ")}"
    end
    
    out_of_stock.each do |oc|
      self.order_copies.delete(oc)
    end
    
    calculate_total
    
    self.shopping_cart.shopping_cart_copies = []
    self.shopping_cart_id = nil
    self.confirmed = true
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
  
  def delivery_short
    case delivery_method.to_i
    when 1
      "Post"
    when 2
      "Pick-up"
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
  
  def pickup_point_text
    return "" if delivery_method != 2
    
    "Pickup point: #{pickup_point.present? ? pickup_point.name : "#{other_pickup} (other)"}"
  end
  
  def payment_text
    "Payment by #{payment_name}"
  end
  
  def delivery_text
    "Delivery by #{delivery_name}"
  end
  
  def full_address
    x = address
    x += "\n" if (city.present? || pin_code.present?)
    x += city if city.present?
    x += " - " if (city.present? && pin_code.present?)
    x += pin_code if pin_code.present?
    return x
  end
  
  def formatted_postage_amount
    RupeeHelper.to_rupee(postage_amount || 0)
  end
  
  def formatted_total_amount
    RupeeHelper.to_rupee(total_amount || 0)
  end
  
  def get_hash
    {
      :name => name,
      :email => email,
      :address => full_address,
      :phone => phone,
      :other_info => other_info,
      :payment_text => payment_text,
      :delivery_text => delivery_text,
      :pickup_point_text => pickup_point_text,
      :postage_amount => formatted_postage_amount,
      :total_amount => formatted_total_amount
    }
  end
  
  def amount_hash
    {
      :postage_amount => formatted_postage_amount,
      :total_amount => formatted_total_amount
    }
  end
  
  def revert_copies
    self.order_copies.each do |oc|
      oc.revert_copy
      oc.destroy
    end
    self.order_copies = []
  end
  
  def add_copy(copy_id)
    copy = Copy.find(copy_id)
    return if copy.in_stock = false || copies.include?(copy)
    
    if copy.new_copy
      copy.number -= 1
    else
      copy.set_stock = false
    end
    copy.save
    
    oc = self.order_copies.build
    oc.copy = copy
    oc.save
  end
end
