class Copy < ActiveRecord::Base
  attr_accessible :price, :stock

  before_validation :prevent_save_if_base, :set_accession_id
  after_initialize :init
  after_save :check_book_stock
  after_destroy :check_book_stock

  belongs_to :edition
  has_many :order_copies, :dependent => :destroy
  has_one :stock_taking

  validates :edition, presence: true
  validates :accession_id, presence: true, uniqueness: true
  validates :copy_number, numericality: { only_integer: true }
  validates :stock, numericality: { only_integer: true }
  validates :price, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }
  validates :cost_price, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }
  validates :new_copy, inclusion: { in: [true, false] }
  validates :condition_rating,
    numericality: {
      only_integer: true,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 5 
    }

  scope :stocked, -> { where{stock > 0} }
  scope :unstocked, -> { where{stock <= 0} }
  scope :new_or_stocked, -> { where{(new_copy == true) | (stock > 0)} }
  scope :includes_edition, -> { includes{[edition.publisher, edition.format]} }

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
    unless edition.blank?
      self.copy_number ||= find_copy_number
      self.accession_id ||= "#{book.accession_id}-#{copy_number}"
    end
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

  def self.find_used_or_new(copy_id)
    copy = UsedCopy.find_by_id(copy_id) || NewCopy.find_by_id(copy_id)
    raise ActiveRecord::RecordNotFound if !copy
    return copy
  end

  def profit_percentage
    return 0 if price.to_i == 0
    (((price - cost_price.to_f) / price.to_f) * 100).to_i
  end
end
