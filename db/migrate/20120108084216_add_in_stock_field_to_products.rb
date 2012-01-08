class AddInStockFieldToProducts < ActiveRecord::Migration
  def change
    change_table :products do |t|
      t.boolean :in_stock
    end
  end
end
