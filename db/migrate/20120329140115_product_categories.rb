class ProductCategories < ActiveRecord::Migration
  def change
    change_table :products do |t|
      t.integer :language_id
      t.integer :product_type_id
      t.integer :content_type_id
    end
    add_index :products, :language_id
    add_index :products, :product_type_id
    add_index :products, :content_type_id
    
    change_table :editions do |t|
      t.remove :language_id
    end
    
    drop_table :product_tags
    
    create_table :product_types do |t|
      t.string :name
      t.timestamps
    end
    add_index :product_types, :name
    
    
    create_table :content_types do |t|
      t.string :name
      t.timestamps
    end
    add_index :content_types, :name
  end
end
