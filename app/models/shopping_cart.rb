class ShoppingCart < ActiveRecord::Base
  default_scope includes(:order, :copies)
  
  has_many :shopping_cart_copies, :dependent => :destroy, :include => :copy
  has_many :copies, :through => :shopping_cart_copies, :as => :copy
  has_one :order, :dependent => :destroy
  
  def self.clear_old
    cleared = 0
    cleared_orders = 9
    ShoppingCart.where("updated_at < current_timestamp - INTERVAL '14 days'").each do |x|
      cleared_orders += 1 if x.order.present?
      x.destroy
      cleared += 1
    end
    
    puts "Cleared #{cleared} shopping carts & #{cleared_orders} linked orders"
  end
  
  def add_copy=(copy_id)
    self.shopping_cart_copies.build(:copy_id => copy_id) unless copy_ids.include? copy_id.to_i
  end
  
  def remove_copy=(copy_id)
    scc = shopping_cart_copies.where(:copy_id => copy_id).first
    self.shopping_cart_copies.delete(scc) if scc
  end
  
  def change_number=(data)
    scc = shopping_cart_copies.where(:copy_id => data["copy_id"].to_i).first
    if scc
      scc.number = data["number"]
      scc.save
      self.shopping_cart_copies.reload
    end
  end
  
  def total
    price = 0
    shopping_cart_copies.each do |c|
      price += c.price
    end
    
    return price
  end
  
  def empty=(bool)
    if bool
      self.shopping_cart_copies.clear
    end
  end
  
  def items
    new_record? ? 0 : shopping_cart_copies.length
  end
end