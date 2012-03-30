class ShoppingCartAndOrderCopyRelation < ActiveRecord::Migration
  def change
    drop_table :shopping_carts_copies
    drop_table :orders_copies
    
    create_table :shopping_carts_copies do |t|
      t.integer :shopping_cart_id
      t.integer :copy_id
      t.integer :number
    end
    
    create_table :orders_copies do |t|
      t.integer :order_id
      t.integer :copy_id
      t.integer :number
    end
  end
end
