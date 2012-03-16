class AddInStockFlagToCopies < ActiveRecord::Migration
  def change
    
    add_index :editions, :publisher_id
    add_index :products, :in_stock
    add_index :themes, :name
    add_index :theme_icons, :theme_id
    add_index :products_themes, [:product_id, :theme_id], :unique => true
    add_index :products_themes, :product_id
    
    change_table :copies do |t|
      t.boolean :in_stock
    end
    
    add_index :copies, :in_stock
  end
end
