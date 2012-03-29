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
      t.integer :country_id
    end
    add_index :products, :publisher_id
    add_index :products, :country_id
    
    
    
    change_table :editions do |t|
      t.integer :language_id
    end
    add_index :editions, :language_id
    
    
    
    create_table :languages do |t|
      t.string :name
      t.timestamps
    end
    add_index :languages, :name
    
    
    
    create_table :countries do |t|
      t.string :name
      t.timestamps
    end
    add_index :countries, :name
    
  end
end
