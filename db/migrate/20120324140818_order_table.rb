class OrderTable < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :step
      t.integer :shopping_cart_id
      
      t.integer :delivery_method
      t.integer :pickup_point_id
      t.integer :payment_method
      t.text :other_pickup
      
      t.string :name
      t.string :email
      t.string :phone
      t.text :address
      t.string :city
      t.string :pin_code
      
      t.text :other_info
      
      t.integer :postage_amount
      t.integer :total_amount
      
      t.timestamps
    end
    
    add_index :orders, :step
    add_index :orders, :shopping_cart_id
    add_index :orders, :pickup_point_id
    add_index :orders, :name
    add_index :orders, :email
    
    create_table :pickup_points do |t|
      t.string :name
      t.timestamps
    end
    
    create_table :orders_copies, :id => false do |t|
      t.integer :order_id
      t.integer :copy_id
    end
    
    add_index :orders_copies, [:order_id, :copy_id], :unique => true
    add_index :orders_copies, [:order_id]
  end
end
