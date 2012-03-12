class RemoveGenres < ActiveRecord::Migration
  def up
    drop_table "genres"
    drop_table "products_genres"
  end

  def down
    create_table "genres", :force => true do |t|
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  
    add_index "genres", ["name"], :name => "index_genres_on_name", :unique => true
    
    create_table "products_genres", :id => false, :force => true do |t|
      t.integer "product_id"
      t.integer "genre_id"
    end
  
    add_index "products_genres", ["product_id", "genre_id"], :name => "index_products_genres_on_product_id_and_genre_id", :unique => true
    add_index "products_genres", ["product_id"], :name => "index_products_genres_on_product_id"
  end
end
