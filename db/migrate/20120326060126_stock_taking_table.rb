class StockTakingTable < ActiveRecord::Migration
  def change
    create_table :stock_taking do |t|
      t.integer :copy_id
    end
    
    add_index :stock_taking, :copy_id
  end
end
