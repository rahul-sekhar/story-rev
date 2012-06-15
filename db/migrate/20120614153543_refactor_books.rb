class RefactorBooks < ActiveRecord::Migration
  def book_foreign_key_tables
    %w[cover_images editions other_fields products_awards products_collections]
  end
  
  def up
    rename_table :products, :books
    
    change_table :books do |t|
      t.remove :flipkart_id, :content_type_id, :in_stock_at, :out_of_stock_at
      t.rename :product_type_id, :book_type_id
    end
    
    book_foreign_key_tables.each do |t|
      rename_column t, :product_id, :book_id
    end
    
    rename_table :product_types, :book_types
    rename_table :products_awards, :books_awards
    rename_table :products_collections, :books_collections
    
    drop_table :content_types
    drop_table :theme_icons
  end
  
  def down
    create_table :content_types do |t|
      t.string :name
      t.timestamps
    end
    
    create_table :theme_icons do |t|
      t.integer  :theme_id
      t.string   :filename
      t.timestamps
    end
    
    rename_table :book_types, :product_types
    rename_table :books_awards, :products_awards
    rename_table :books_collections, :products_collections
    
    book_foreign_key_tables.each do |t|
      rename_column t, :book_id, :product_id
    end
    
    change_table :books do |t|
      t.string :flipkart_id
      t.integer :content_type_id
      t.rename :book_type_id, :product_type_id
    end
    
    rename_table :books, :products
  end
end
