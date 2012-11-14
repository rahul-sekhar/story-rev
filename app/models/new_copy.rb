class NewCopy < Copy
  default_scope -> { where(new_copy: true) }
  attr_accessible :required_stock, :profit_percentage

  attr_writer :profit_percentage

  before_save :calculate_cost_price
  after_save :update_book_date

  validates :required_stock, 
    numericality: { 
      only_integer: true, 
      greater_than_or_equal_to: 0 
    }, 
    allow_blank: true

  validates :profit_percentage,
    numericality: { 
      only_integer: true, 
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 100
    }, 
    allow_blank: true

  def init
    self.new_copy = true
    self.stock ||= 0
    @prev_stock = stock
    self.condition_rating ||= 5
  end

  def update_book_date
    book.set_book_date if @prev_stock <= 0 && stock > 0
    @prev_stock = stock
  end

  def calculate_cost_price
    self.cost_price = (price - (price.to_f * @profit_percentage.to_f / 100.0).round) if @profit_percentage.present?
  end
end