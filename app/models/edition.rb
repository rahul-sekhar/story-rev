class Edition < ActiveRecord::Base
  attr_accessible :isbn, :format_name, :publisher_name
  belongs_to :format
  belongs_to :product
  belongs_to :publisher
  has_many :copies, :dependent => :destroy
  
  before_validation :convert_raw_isbn
  
  validates :isbn, :uniqueness => true, :allow_blank => true
  validates :format, :presence => true
  validates :raw_isbn, :numericality => { :only_integer => true }, :allow_blank => true
  
  validates_associated :publisher
  
  def format_name
    format ? format.name : nil
  end
  
  def format_name=(name)
    self.format = name.present? ? (Format.name_is(name).first || Format.new({ :name => name })) : nil
  end
  
  def publisher_name=(name)
    self.publisher = name.present? ? (Publisher.name_is(name).first || Publisher.new({ :name => name })) : nil
  end
  
  def publisher_name
    publisher ? publisher.name : nil
  end
  
  def convert_raw_isbn
    self.raw_isbn = isbn.to_s.gsub("-", "")
  end
  
  def get_hash
    {
      :id => id,
      :format_name => format_name,
      :publisher_name => publisher_name,
      :isbn => isbn
    }
  end
end
