class CoverImages < ActiveRecord::Migration
  def change
    change_table :products do |t|
      t.remove :cover_image
    end
    
    create_table :cover_images do |t|
      t.integer :product_id
      t.string :filename
      t.timestamps
    end
  end
end
