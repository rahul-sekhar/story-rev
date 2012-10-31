class NewCopy < Copy
  default_scope -> { where(new_copy: true) }
  attr_accessible :required_stock
  attr_accessor :prev_stock

  after_save :update_book_date

  validates :required_stock, 
    numericality: { 
      only_integer: true, 
      greater_than_or_equal_to: 0 
    }, 
    allow_blank: true

  def init
    self.new_copy = true
    self.stock ||= 0
    self.prev_stock = stock
    self.condition_rating ||= 5
  end

  def update_book_date
    book.set_book_date if prev_stock <= 0 && stock > 0
    self.prev_stock = stock
  end
end