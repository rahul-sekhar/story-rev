class Copy < ActiveRecord::Base
  attr_accessible :condition_rating, :condition_description, :price, :new_copy, :stock, :required_stock

  before_validation :set_accession_id
  after_initialize :init
  after_save :check_book_stock
  after_destroy :check_book_stock
  after_create :set_book_date
  
  belongs_to :edition
  has_many :shopping_cart_copies, :dependent => :destroy
  has_many :order_copies, :dependent => :destroy
  has_one :stock_taking
  
  # Protect 'stock', it should instead be set using 'set_stock'
  attr_protected :stock
  
  validates :accession_id, :presence => true, :uniqueness => true
  validates :copy_number, :presence => true, :numericality => { :only_integer => true }
  validates :condition_rating, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 5 }
  validates :price, :numericality => { :only_integer => true }
  
  scope :stocked, where("stock > 0")
  scope :unstocked, where("stock <= 0")
  scope :new_copies, where(:new_copy => true)
  scope :used_copies, where(:new_copy => false)
  
  scope :new_or_stocked, where("stock > 0 OR new_copy = TRUE")
  
  def init
    self.new_copy = false if new_copy.nil?
    self.stock ||= new_copy ? 0 : 1
    self.condition_rating ||= new_copy ? 5 : 3
  end
  
  # Function to return copies that don't have the same price, edition and condition rating, out of an array of copies
  # Used to prevent showing multiple similar copies for a book
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
  
  # The copy is in stock if its stock is above 0
  def in_stock
    stock > 0
  end
  
  def set_accession_id
    self.copy_number ||= find_copy_number
    self.accession_id ||= "#{book.accession_id}-#{copy_number}"
  end
  
  def find_copy_number
    last_copy = book.copies.where("copy_number IS NOT NULL").order("copy_number DESC").limit(1).first
    return last_copy.present? ? last_copy.copy_number.to_i + 1 : 1
  end
  
  def set_stock=(value)
    if new_copy
      # Update the book date if a new copy that was out of stock has come back in stock
      book.set_book_date if self.stock <= 0 && value > 0
      self.stock = value
    else
      self.stock = (value == false || value == 0) ? 0 : 1
    end
    save
  end
  
  # Set the book date if a fresh copy has been created
  def set_book_date
    book.set_book_date if (!new_copy && stock > 0)
  end
  
  def book
    edition.book
  end
  
  def check_book_stock
    book.check_stock
  end
end
