class RefactorCopies < ActiveRecord::Migration
  def up
    create_table :used_copies do |t|
      t.integer :edition_id
      t.integer :copy_number
      t.string :condition_description
      t.integer :condition_rating, :limit => 2
      t.integer :price
      t.integer :order_id
      t.timestamps
    end
    
    create_table :new_copies do |t|
      t.integer :edition_id
      t.integer :copy_number
      t.integer :stock
      t.integer :price
      t.integer :required_stock
      t.timestamps
    end
  end
  
  def down
    
  end
end
