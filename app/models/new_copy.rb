class NewCopy < Copy
  default_scope -> { where(:new_copy => true) }
  attr_accessible :required_stock

  def init
    self.new_copy = true
    self.stock ||= 0
    self.condition_rating ||= 5
  end

  def set_stock=(value)
    # Update the book date if a new copy that was out of stock has come back in stock
    book.set_book_date if self.stock <= 0 && value > 0 && !new_record?
    self.stock = value
  end
end