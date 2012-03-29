class DropProductTags < ActiveRecord::Migration
  def change
    drop_table :products_product_tags
  end
end
