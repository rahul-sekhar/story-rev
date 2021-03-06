class Edition < ActiveRecord::Base
  extend NameTags

  attr_accessible :isbn, :format_name, :publisher_name, :language_name
  
  belongs_to :format
  belongs_to :language
  belongs_to :book
  belongs_to :publisher
  
  has_many :new_copies
  has_many :used_copies
  has_many :copies, readonly: true, dependent: :destroy

  name_tag :format, :language, :publisher
  
  before_validation :convert_raw_isbn
  
  validates :book, presence: true
  validates :format, presence: true
  validates :isbn, 
    length: { maximum: 50 }, 
    format: { with: /\A\d+(?:-?\d+)*\z/ }, 
    allow_blank: true
  validates :raw_isbn, 
    numericality: { only_integer: true }, 
    if: "isbn.present?"
  
  validates_associated :publisher
  validates_associated :format
  validates_associated :language
  
  def convert_raw_isbn
    self.raw_isbn = isbn.to_s.gsub("-", "")
    return nil
  end

  def language_name
    language ? language.name : "English"
  end
  
  def default_cost_price
    default = DefaultCostPrice.where(format_id: format_id, book_type_id: book.book_type_id).first
    if default.present?
      return default.cost_price
    else
      return ConfigData.access.default_cost_price
    end
  end

  def default_percentage
    pub_id = publisher.present? ? self.publisher_id : book.publisher_id
    default = DefaultPercentage.where(publisher_id: pub_id).first
    if default.present?
      return default.percentage
    else
      return ConfigData.access.default_percentage
    end
  end
end
