class Copy < ActiveRecord::Base
  before_validation :set_accession_id
  after_initialize :init
  after_save :check_product_stock
  after_destroy :check_product_stock
  
  belongs_to :edition
  validates :accession_id, :presence => true, :uniqueness => true
  validates :condition_rating, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 5 }
  validates :price, :numericality => { :only_integer => true }
  
  scope :stocked, where(:in_stock => true)
  
  def init
    self.in_stock = true if in_stock.nil?
    self.condition_rating ||= 3
  end 
  
  def formatted_price
    RupeeHelper::to_rupee(price)
  end
  
  def get_hash
    return {
      :id => id,
      :accession_id => accession_id,
      :price => price,
        :formatted_price => formatted_price,
        :condition_description => condition_description,
        :condition_rating => condition_rating
    }
  end
  
  def set_accession_id
    self.accession_id = find_accession_id
  end
  
  def find_accession_id
    base_acc = product.accession_id
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
    product.check_stock if in_stock
  end
  
  def set_stock=(value)
    if (in_stock != value)
      self.in_stock = value
      check_product_stock
    end
  end
end
