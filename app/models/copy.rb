class Copy < ActiveRecord::Base
  before_validation :set_accession_id
  after_initialize :init
  before_save :set_in_stock
  after_save :check_product_stock
  after_destroy :check_product_stock
  
  belongs_to :edition
  has_many :shopping_cart_copies, :dependent => :destroy
  has_many :order_copies, :dependent => :destroy
  has_one :stock
  
  validates :accession_id, :presence => true, :uniqueness => true
  validates :condition_rating, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 5 }
  validates :price, :numericality => { :only_integer => true }
  
  scope :stocked, where(:in_stock => true)
  scope :unstocked, where(:in_stock => false)
  scope :new_copies, where(:new_copy => true)
  scope :used_copies, where(:new_copy => false)
  
  scope :new_or_stocked, where("in_stock = TRUE OR new_copy = TRUE")
  
  def init
    self.in_stock = true if in_stock.nil?
    self.new_copy = false if new_copy.nil?
    self.limited_copies = false if limited_copies.nil?
    self.number ||= 0
    self.condition_rating ||= 3
  end 
  
  def get_hash
    if new_copy
      return {
        :id => id,
        :accession_id => accession_id,
        :price => price,
        :formatted_price => formatted_price,
        :new_copy => new_copy,
        :limited_copies => limited_copies,
        :number => number
      }
    else
      return {
        :id => id,
        :accession_id => accession_id,
        :price => price,
        :formatted_price => formatted_price,
        :condition_description => condition_description,
        :condition_rating => condition_rating,
        :new_copy => new_copy
      }
    end
  end
  
  def set_in_stock
    self.in_stock = !limited_copies || (number > 0) if new_copy
    return nil
  end
  
  def set_stock=(value)
    if (!new_copy && in_stock != value)
      self.in_stock = value
      save
      check_product_stock
    end
  end
  
  def set_accession_id
    self.accession_id = find_accession_id
  end
  
  def find_accession_id
    base_acc = product.accession_id
    return accession_id if accession_id.to_s[0,9] == base_acc
    
    last_copy = Copy.where('accession_id LIKE ?', "#{base_acc}%").order("accession_id DESC").first
    
    if last_copy.present?
      new_acc = last_copy.accession_id[10,3].to_i + 1
      "#{base_acc}-#{"%03d" % new_acc}"
    else
      "#{base_acc}-001"
    end
  end
  
  def product
    edition.product
  end
  
  def check_product_stock
    product.check_stock
  end
  
  def formatted_price
    RupeeHelper::to_rupee(price)
  end
  
  def self.condition_to_words(condition)
    case condition
    when 1
      "acceptable"
    when 2
      "acceptable"
    when 3
      "good"
    when 4
      "excellent"
    when 5
      "like new"
    end
  end
end
