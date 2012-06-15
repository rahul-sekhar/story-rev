class RefactorCopies < ActiveRecord::Migration
  def up
    create_table :used_copies do |t|
      t.integer :edition_id
      t.integer :copy_number
      t.string :condition_description
      t.integer :condition_rating, :limit => 2
      t.integer :price
      t.integer :order_id
      t.boolean :ticked
      t.timestamps
    end
    add_index :used_copies, :edition_id
    add_index :used_copies, :copy_number
    add_index :used_copies, :price
    add_index :used_copies, :condition_rating
    add_index :used_copies, :order_id
    
    create_table :new_copies do |t|
      t.integer :edition_id
      t.integer :copy_number
      t.integer :stock
      t.integer :price
      t.integer :required_stock
      t.timestamps
    end
    add_index :new_copies, :copy_number
    add_index :new_copies, :edition_id
    add_index :new_copies, :price
    add_index :new_copies, :stock
    
    create_table :orders_new_copies do |t|
      t.integer :order_id
      t.integer :new_copy_id
      t.integer :number
      t.boolean :ticked
      t.timestamps
    end
    add_index :orders_new_copies, :order_id
    add_index :orders_new_copies, : new_copy_id
    
    create_table :shopping_carts_used_copies, :id => false do |t|
      t.integer :shopping_cart_id
      t.integer :used_copy_id
    end
    add_index :shopping_carts_used_copies, :shopping_cart_id
    add_index :shopping_carts_used_copies, [:shopping_cart_id, :used_copy_id]
    
    create_table :shopping_carts_new_copies do |t|
      t.integer :shopping_cart_id
      t.integer :new_copy_id
      t.integer :number
    end
    add_index :shopping_carts_new_copies, :shopping_cart_id
    add_index :shopping_carts_new_copies, [:shopping_cart_id, :new_copy_id]
    
    
    drop_table :shopping_carts_copies
    drop_table :orders_copies
    drop_table :copies
  end
  
  def down
    drop_table :used_copies
    drop_table :new_copies
    drop_table :orders_new_copies
    drop_table :shopping_carts_used_copies
    drop_table :shopping_carts_new_copies
    
    create_table :copies do |t|
      t.integer  :edition_id
      t.string   :accession_id
      t.string   :condition_description
      t.integer  :condition_rating, :limit => 2
      t.integer  :price
      t.boolean  :in_stock
      t.boolean  :new_copy
      t.boolean  :limited_copies
      t.integer  :number
      t.integer  :copy_number
      t.timestamps
    end
    add_index "copies", ["accession_id"], :name => "index_copies_on_accession_id"
    add_index "copies", ["condition_rating"], :name => "index_copies_on_condition_rating"
    add_index "copies", ["copy_number"], :name => "index_copies_on_copy_number"
    add_index "copies", ["edition_id"], :name => "index_copies_on_edition_id"
    add_index "copies", ["in_stock"], :name => "index_copies_on_in_stock"
    add_index "copies", ["limited_copies"], :name => "index_copies_on_limited_copies"
    add_index "copies", ["new_copy"], :name => "index_copies_on_new_copy"
    add_index "copies", ["number"], :name => "index_copies_on_number"
    
    create_table "orders_copies", :force => true do |t|
      t.integer "order_id"
      t.integer "copy_id"
      t.integer "number"
      t.boolean "ticked"
    end
    
    create_table "shopping_carts_copies", :force => true do |t|
      t.integer "shopping_cart_id"
      t.integer "copy_id"
      t.integer "number"
    end
  end
end
