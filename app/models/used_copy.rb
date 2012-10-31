class UsedCopy < Copy
  default_scope -> { where(new_copy: false) }
  attr_accessible :condition_rating, :condition_description
  
  # Set the book date if a fresh copy has been created
  after_create :set_book_date

  validates :condition_rating, 
    numericality: { 
      only_integer: true,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 5 
    }

  validates :condition_description, length: { maximum: 255 }

  def init
    self.new_copy = false
    self.stock ||= 1
    self.condition_rating ||= 3
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

  def set_book_date
    book.set_book_date if stock > 0
  end
end