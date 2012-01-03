class Edition < ActiveRecord::Base
  attr_accessible :isbn, :base_price, :format_name
  belongs_to :format
  belongs_to :product
  has_many :copies, :dependent => :destroy
  
  before_validation :convert_raw_isbn
  
  validates :raw_isbn, :numericality => { :only_integer => true }
  validates :base_price, :numericality => { :only_integer => true }
  
  def format_name
    format ? format.name : nil
  end
  
  def format_name=(name)
    self.format = name.present? ? (Format.name_is(name).first || Format.new({ :name => name })) : nil
  end 
  
  def formatted_base_price
    RupeeHelper::to_rupee(base_price)
  end
  
  def convert_raw_isbn
    self.raw_isbn = isbn.gsub("-", "")
  end
  
  def get_hash
    {
      :id => id,
      :format_name => format_name,
      :base_price => base_price,
      :formatted_base_price => formatted_base_price,
      :isbn => isbn
    }
  end
end
