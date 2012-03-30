class NewCopiesExtraTables < ActiveRecord::Migration
  def change
    create_table "orders_new_copies", :id => false do |t|
      t.integer "order_id"
      t.integer "new_copy_id"
    end
  
    add_index "orders_new_copies", ["order_id", "new_copy_id"], :unique => true
    add_index "orders_new_copies", ["order_id"]
    
    
    create_table "shopping_carts_new_copies", :id => false do |t|
      t.integer "shopping_cart_id"
      t.integer "new_copy_id"
    end
  
    add_index "shopping_carts_new_copies", ["shopping_cart_id", "new_copy_id"], :name => "id_index_on_shopping_carts_new_copies", :unique => true
    add_index "shopping_carts_new_copies", ["shopping_cart_id"]
    
    
    remove_column :stock_taking, :copy_id
    
    change_table :stock_taking do |t|
      t.references :copy_type, :polymorphic => true
    end
    
  end
end
