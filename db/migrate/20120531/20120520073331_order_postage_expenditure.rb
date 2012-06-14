class OrderPostageExpenditure < ActiveRecord::Migration
  def up
    change_table :orders do |t|
      t.integer :postage_expenditure
      t.text :notes
    end
    
    add_index :orders, :created_at
  end
  
  def down
    change_table :orders do |t|
      t.remove :postage_expenditure, :notes
    end
    
    remove_index :orders, :created_at
  end
end
