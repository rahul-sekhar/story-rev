class Copy < ActiveRecord::Base
  include CopyBase
  
  before_validation :set_accession_id
  after_initialize :init
  after_save :check_product_stock
  after_destroy :check_product_stock
  
  belongs_to :edition
  has_and_belongs_to_many :shopping_carts, :join_table => :shopping_carts_copies, :uniq => true
  has_and_belongs_to_many :orders, :join_table => :orders_copies, :uniq => true
  has_one :stock
  
  validates :accession_id, :presence => true, :uniqueness => true
  validates :condition_rating, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 5 }
  validates :price, :numericality => { :only_integer => true }
  
  scope :stocked, where(:in_stock => true)
  scope :unstocked, where(:in_stock => false)
  
  def init
    self.in_stock = true if in_stock.nil?
    self.condition_rating ||= 3
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
  
  def set_stock=(value)
    if (in_stock != value)
      self.in_stock = value
      save
      check_product_stock
    end
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
