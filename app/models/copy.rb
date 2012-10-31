class Copy < ActiveRecord::Base
  attr_accessible :price, :stock

  before_validation :prevent_save_if_base, :set_accession_id
  after_initialize :init
  after_save :check_book_stock
  after_destroy :check_book_stock

  belongs_to :edition
  has_many :shopping_cart_copies, :dependent => :destroy
  has_many :order_copies, :dependent => :destroy
  has_one :stock_taking

  validates :accession_id, presence: true, uniqueness: true
  validates :copy_number, presence: true, numericality: { only_integer: true }
  validates :stock, presence: true, numericality: { only_integer: true }
  validates :price, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }

  scope :stocked, -> { where("stock > 0") }
  scope :unstocked, -> { where("stock <= 0") }

  def init
  end

  def prevent_save_if_base
    return true unless (self.class == Copy)
    logger.fatal "Models should not be saved using the Copy class - use the NewCopy or UsedCopy classes instead"
    return false
  end

  # The copy is in stock if its stock is above 0
  def in_stock?
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

  def book
    edition.book if edition.present?
  end

  def check_book_stock
    book.check_stock
  end
end
