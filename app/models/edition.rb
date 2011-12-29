class Edition < ActiveRecord::Base
  belongs_to :format
  belongs_to :product
  has_many :copies, :dependent => destroy
  
  validates :isbn, :numericality => { :only_integer => true }
  validates :base_price, :numericality => { :only_integer => true }
end
