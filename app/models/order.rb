class Order < ActiveRecord::Base
  after_initialize :init
  after_validation :change_step_if_invalid
  before_save :remove_unecessary_fields
  
  attr_accessible :next_step, :delivery_method, :pickup_point_id, :other_pickup, :payment_method
  
  attr_reader :next_step
  
  belongs_to :pickup_point
  belongs_to :shopping_cart
  
  # Delivery_method (set on step 1)
  # 1 - Speed Post
  # 2 - Pickup Point
  validates :delivery_method, :inclusion => { :in => [1,2], :message => "must be chosen" }
  
  # Delivery_method (set on step 2)
  # 1 - Online bank transfer
  # 2 - Cheque
  validates :payment_method, :inclusion => { :in => [1,2], :message => "must be chosen" }
  
  
  def init
    self.step ||= 1
    self.delivery_method ||= 1
    self.payment_method ||= 1
  end
  
  def change_step_if_invalid
    return if errors.size == 0
    
    valid_step = step
    
    if attr_invalid?(:delivery_method)
      valid_step = 1
    elsif attr_invalid?(:payment_method)
      valid_step = 2
    elsif attr_invalid?(:next_step)
      valid_step = 1
    end
    
    self.step = [step, valid_step].min
  end
  
  def attr_invalid?(attr)
    errors[attr].present?
  end
  
  
  def next_step=(n)
    self.step = n.to_i if (n.to_i < 4)
  end
  
  def first_step?
    step == 1
  end
  
  def remove_unecessary_fields
    # Remove pickup point if it is unrequired
    if (delivery_method != 2)
      self.pickup_point_id = nil
    else
      self.pickup_point_id ||= 0
    end
    
    # Remove other pickup text if it is unrequired
    if (other_pickup.present? && (delivery_method != 2 || pickup_point_id != 0))
      self.other_pickup = nil
    end
  end
end
