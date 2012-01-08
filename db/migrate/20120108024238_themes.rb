class Themes < ActiveRecord::Migration
  def change
    create_table :themes do |t|
      t.string :name
    end
    
    create_table :theme_icons do |t|
      t.integer :theme_id
      t.string :filename
    end
    
    create_table :products_themes, :id => false do |t|
      t.integer :product_id
      t.integer :theme_id
    end
  end
end
