class ShoppingCart < ActiveRecord::Base
  default_scope includes(:order, :copies)
  
  has_and_belongs_to_many :copies, :join_table => :shopping_carts_copies, :uniq => true
  has_one :order
  
  def add_copy=(copy_id)
    copy = Copy.find(copy_id)
    self.copies << copy unless copy_ids.include? copy_id
    save
  end
  
  def remove_copy=(copy_id)
    copy = Copy.find(copy_id)
    self.copies.delete(copy)
  end
  
  def total
    price = 0
    copies.each do |c|
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
    new_record? ? 0 : copy_ids.length
  end
end