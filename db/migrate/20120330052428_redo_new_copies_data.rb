class RedoNewCopiesData < ActiveRecord::Migration
  def change
    drop_table :new_copies
    drop_table :orders_new_copies
    drop_table :shopping_carts_new_copies
    drop_table :stock_taking
    
    create_table :stock_taking do |t|
      t.integer :copy_id
      t.timestamps
    end
    add_index :stock_taking, :copy_id
    
    change_table :copies do |t|
      t.boolean :new_copy
      t.boolean :limited_copies
      t.integer :number
    end
    add_index :copies, :new_copy
    add_index :copies, :number
    add_index :copies, :limited_copies
  end
end
