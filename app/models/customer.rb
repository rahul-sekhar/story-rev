class Customer < ActiveRecord::Base
  attr_accessible :delivery_method, :pickup_point_id, :other_pickup, :payment_method_id, :name, :email, :phone, :address, :city, :pin_code, :other_info

  after_initialize :init
  before_save :remove_unecessary_fields

  belongs_to :order
  belongs_to :pickup_point
  belongs_to :shopping_cart
  belongs_to :payment_method

  validates :order, presence: true

  # Delivery method (step 1)
  # 1 - Speed Post
  # 2 - Pickup Point
  validates :delivery_method, inclusion: { in: [1,2], message: "must be chosen" }
  validates :pickup_point, presence: true, if: "delivery_method == 2 && pickup_point_id != 0"

  # Payment method (step 2)
  # 1 - Online bank transfer
  # 2 - Cheque
  # 3 - Cash
  validates :payment_method_id, 
    inclusion: { in: [1,2,3], message: "must be chosen" },
    unless: "step < 2"

  # Details (step 3)
  validates :name, presence: true, 
    length: { maximum: 150 },
    unless: "step < 3"

  validates :email, presence: true, 
    length: { maximum: 100 },
    format: { with: /.+@.+\..+/ },
    unless: "step < 3"

  validates :phone, length: { maximum: 40 }
  validates :city, length: { maximum: 40 }
  validates :pin_code, length: { maximum: 10 }

  def init
    @step = 1
  end

  def step=(val)
    val = (1..4).include?(val.to_i) ? val.to_i : 4

    # Check the validity of each step below the current one
    (1..(val - 1)).each do |x|
      @step = x
      if invalid?
        errors.clear
        return
      end
    end
    @step = val
  end

  def step
    @step
  end

  def set_defaults
    self.delivery_method ||= 1 if @step == 1
    self.payment_method_id ||= 1 if @step == 2
  end
  
  def remove_unecessary_fields
    # Remove pickup point if it is unrequired
    self.pickup_point_id = nil if delivery_method != 2
    
    # Remove other pickup text if it is unrequired
    self.other_pickup = nil if (delivery_method != 2 || pickup_point_id != 0)
  end
end