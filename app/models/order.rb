class Order < ActiveRecord::Base
  after_initialize :init
  after_validation :change_step_if_invalid
  before_save :remove_unecessary_fields, :refresh_if_incomplete, :calculate_total, :check_transaction
  
  attr_accessible :next_step, :delivery_method, :pickup_point_id, 
    :other_pickup, :payment_method_id, :name, :email, :phone, :address, 
    :city, :pin_code, :other_info, :confirmed, :paid, :packaged, 
    :posted, as: [:default, :admin]
  
  attr_accessible :postage_expenditure, :notes, :account_id, as: [:admin]
  
  attr_reader :next_step, :out_of_stock
  attr_writer :out_of_stock
  
  has_many :order_copies, :dependent => :destroy, :include => :copy
  has_many :copies, :through => :order_copies, :as => :copy
  has_many :transactions
  has_many :extra_costs, order: "created_at ASC"
  
  belongs_to :pickup_point
  belongs_to :shopping_cart
  belongs_to :payment_method
  belongs_to :account
  
  belongs_to :transaction, :dependent => :destroy
  belongs_to :postage_transaction, :class_name => "Transaction", :dependent => :destroy
  
  # Delivery method (step 1)
  # 1 - Speed Post
  # 2 - Pickup Point
  validates :delivery_method, :inclusion => { :in => [1,2], :message => "must be chosen" }, :presence => true
  validates :pickup_point_id, :numericality => { :only_integer => true }, :if => :pickup_delivery?
  
  # Payment method (step 2)
  # 1 - Online bank transfer
  # 2 - Cheque
  # 3 - Cash
  validates :payment_method_id, :inclusion => { :in => [1,2,3], :message => "must be chosen" }, :presence => true, :unless => :below_step_2?
  
  #Details (step 3)
  validates :name, :presence => :true, :unless => :below_step_3?
  validates :email, :presence => :true, :unless => :below_step_3?
  
  scope :complete, where(step: 5)
  
  
  def self.clear_old
    cleared = 0
    Order.where("step <> 5 AND updated_at < current_timestamp - INTERVAL '7 days'").each do |x|
      x.destroy
      cleared += 1
    end
    
    puts "Cleared #{cleared} orders"
  end
  
  def init
    self.step ||= 1
    self.delivery_method ||= 1
    self.payment_method_id ||= 1
    self.postage_expenditure ||= 0
    
    self.payment_method_id = 1 if step == 2 && payment_method_id > 2

    if step == 5
      self.account ||= (payment_method_id == 3 ? ConfigData.access.cash_account : ConfigData.access.default_account)
    end
  end
  
  def change_step_if_invalid
    return if errors.size == 0
    
    valid_step = step
    
    if attr_invalid?(:delivery_method) || attr_invalid?(:pickup_point_id)
      valid_step = 1
    elsif attr_invalid?(:payment_method_id)
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
  
  def check_transaction
    return if step < 5
    
    # Build or update the transactions for the order if it has been paid
    if paid
      trans = self.transaction || self.build_transaction
      trans.update_attributes({
        :credit => total_amount,
        :other_party => name,
        :payment_method_id => payment_method_id,
        :transaction_category_id => 1,
        :account => account,
        :date => paid_date,
        :notes => notes
      })
      trans.save
    
    # Delete any linked transactions if the order has not been paid
    else
      self.transaction.destroy if transaction.present?
    end
  end
  
  
  def postage_expenditure=(amount)
    if (amount && !amount.to_s.is_i?)
      self.errors.messages[:postage_expenditure] = " must be a number"
      return false
    end
    
    if postage_transaction.present?
      if !amount || amount.to_i == 0
        self.postage_transaction.destroy
        self.postage_transaction = nil
      else
        postage_transaction.credit = 0
        postage_transaction.debit = amount
        self.postage_transaction.save
      end
    elsif amount.to_i > 0
      self.create_postage_transaction({
        :transaction_category_id => 2,
        :debit => amount,
        :other_party => name,
        :payment_method_id => 3,
        :account => ConfigData.access.cash_account,
        :date => DateTime.now
      })
    end
  end
  
  def postage_expenditure
    postage_transaction.present? ? postage_transaction.debit.to_i || 0 : 0
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
    order_copies.map{|x| x.number}.inject(:+).to_i
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

    extra_costs.each do |x|
      total += x.amount
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
        if oc.copy.in_stock?
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
    payment_method.name.downcase
  end
  
  def pickup_point_text
    return "" if delivery_method != 2
    
    "Pickup point: #{pickup_point_short_text}"
  end
  
  def pickup_point_short_text
    pickup_point.present? ? pickup_point.name : "#{other_pickup} (other)"
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
  
  def formatted_postage_expenditure
    RupeeHelper.to_rupee(postage_expenditure || 0)
  end
  
  def get_hash
    {
      name: name,
      email: email,
      address: full_address || "",
      phone: phone || "",
      other_info: other_info || "",
      payment_text: payment_text,
      delivery_text: delivery_text,
      pickup_point_text: pickup_point_text || "",
      postage_amount: formatted_postage_amount,
      total_amount: formatted_total_amount,
      postage_expenditure: formatted_postage_expenditure,
      postage_expenditure_val: postage_expenditure == 0 ? nil : postage_expenditure,
      notes: notes || "",
      account_id: account_id
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
    return if !copy.in_stock? || copies.include?(copy)
    
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
  
  # Set the confirmed, paid, packed, posted dates when the properties are set as boolean values
  def confirmed=(val)
    self.confirmed_date = (val && val!= "false") ? confirmed_date || DateTime.now : nil
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
  
  # Get the URL for the order
  def get_url
    return nil if step != 5
    
    # Check to see if the order is pending or completed
    if (confirmed && paid && packaged && posted)
      return Rails.application.routes.url_helpers.admin_orders_url(:host => Rails.application.config.default_host, :selected_id => id)
    else
      return Rails.application.routes.url_helpers.pending_admin_orders_url(:host => Rails.application.config.default_host, :selected_id => id)
    end 
  end
end
