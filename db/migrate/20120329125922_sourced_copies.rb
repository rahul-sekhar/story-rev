class SourcedCopies < ActiveRecord::Migration
  def change
    create_table :new_copies do |t|
      t.integer :edition_id
      t.boolean :limited_copies
      t.integer :number
      t.integer :price
      
      t.timestamps
    end
    
    add_index :new_copies, :edition_id
    add_index :new_copies, :price
    add_index :new_copies, :number
    
    change_table :products do |t|
      t.integer :publisher_id
    end
    
    add_index :products, :publisher_id
    
    change_table :editions do |t|
      t.integer :language_id
    end
    
    create_table :languages do |t|
      t.string :name
      t.timestamps
    end
  end
end
