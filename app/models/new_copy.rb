class NewCopy < Copy
  default_scope -> { where(new_copy: true) }
  attr_accessible :required_stock

  validates :required_stock, 
    numericality: { 
      only_integer: true, 
      greater_than_or_equal_to: 0 
    }, 
    allow_blank: true

  def init
    self.new_copy = true
    self.stock ||= 0
    self.condition_rating ||= 5
  end

  def set_stock=(value)
    # Update the book date if a new copy that was out of stock has come back in stock
    book.set_book_date if !new_record? && self.stock <= 0 && value > 0
    self.stock = value
  end
end