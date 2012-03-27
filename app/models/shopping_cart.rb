class ShoppingCart < ActiveRecord::Base
  default_scope includes(:order, :copies)
  
  has_and_belongs_to_many :copies, :join_table => :shopping_carts_copies, :uniq => true
  has_one :order
  
  def add_copy=(copy_id)
    copy = Copy.find(copy_id)
    self.copies << copy unless copies.include? copy
  end
  
  def remove_copy=(copy_id)
    copy = Copy.find(copy_id)
    self.copies.delete(copy)
  end
  
  def total
    price = 0
    copies.stocked.each do |c|
      price += c.price
    end
    
    return price
  end
  
  def empty=(bool)
    if bool
      self.copies = []
      save
    end
  end
  
  def items
    new_record? ? 0 : copies.length
  end
end