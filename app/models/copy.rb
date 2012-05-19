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
  validates :copy_number, :presence => true, :numericality => { :only_integer => true }
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
  
  def self.filter_unique(src_copies)
    result = []
    src_copies.each do |c|
      unique = true
      result.each do |r|
        if (c.edition_id == r.edition_id) && (c.price == r.price) && (c.condition_rating == r.condition_rating)
          unique = false
          break
        end
      end
      result << c if unique
    end
    return result
  end
  
  def accession_id_sortable
    "#{accession_id.to_i}.#{copy_number}".to_f
  end
  
  def get_hash
    if new_copy
      return {
        :id => id,
        :accession_id => accession_id,
        :accession_id_sortable => accession_id_sortable,
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
        :accession_id_sortable => accession_id_sortable,
        :price => price,
        :formatted_price => formatted_price,
        :condition_description => get_condition_description,
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
    self.copy_number ||= find_copy_number
    self.accession_id ||= "#{product.accession_id}-#{copy_number}"
  end
  
  def find_copy_number
    last_copy = product.copies.where("copy_number IS NOT NULL").order("copy_number DESC").limit(1).first
    return last_copy.present? ? last_copy.copy_number.to_i + 1 : 1
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
  
  def get_condition_description
    condition_description.present? ? condition_description : Copy.condition_to_words(condition_rating)
  end
  
  def self.condition_to_words(condition)
    case condition
    when 1
      "Acceptable"
    when 2
      "Acceptable"
    when 3
      "Good"
    when 4
      "Excellent"
    when 5
      "Like new"
    end
  end
end
