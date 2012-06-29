class Edition < ActiveRecord::Base
  extend NameTags

  attr_accessible :isbn, :format_name, :publisher_name, :language_name
  
  belongs_to :format
  belongs_to :language
  belongs_to :book
  belongs_to :publisher
  
  has_many :new_copies, :dependent => :destroy
  has_many :used_copies, :dependent => :destroy
  has_many :copies, :readonly => true

  name_tag :format, :language, :publisher
  
  before_validation :convert_raw_isbn
  
  validates :format, :presence => true
  validates :language, :presence => true
  validates :isbn, length: { maximum: 255 }
  validates :raw_isbn, 
    numericality: { only_integer: true }, 
    if: "isbn.present?"
  validates :isbn, format: { with: /\A\d+(?:-?\d+)*\z/ }, allow_blank: true
  
  validates_associated :publisher
  validates_associated :format
  validates_associated :language
  
  def init
    self.language_id ||= 1
  end
  
  def convert_raw_isbn
    self.raw_isbn = isbn.to_s.gsub("-", "")
  end
  
  def as_hash
    {
      :id => id,
      :format_name => format_name,
      :publisher_name => publisher_name,
      :language_name => language_name,
      :isbn => isbn
    }
  end
end
