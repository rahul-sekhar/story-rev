class ShoppingCart < ActiveRecord::Migration
  def change
    create_table :shopping_carts do |t|
      t.timestamps
    end
    add_index :shopping_carts, :updated_at
    
    create_table :shopping_carts_copies, :id => false do |t|
      t.integer :shopping_cart_id
      t.integer :copy_id
    end
    
    add_index :shopping_carts_copies, [:shopping_cart_id, :copy_id], :unique => true
    add_index :shopping_carts_copies, :shopping_cart_id
  end
end
