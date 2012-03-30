class ShoppingCartCopy < ActiveRecord::Base
  self.table_name = :shopping_carts_copies
  
  after_initialize :init
  before_save :check_number
  
  belongs_to :shopping_cart
  belongs_to :copy
  
  scope :stocked, where(:copies => { :in_stock => true })
  scope :unstocked, where(:copies => { :in_stock => false })
  
  def init
    self.number ||= 1
  end
  
  def price
    copy.in_stock ? copy.price * number : 0
  end
  
  def check_number
    self.number = 1 unless (copy.new_copy && number > 0)
  end
end
