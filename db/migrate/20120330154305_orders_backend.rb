class OrdersBackend < ActiveRecord::Migration
  def change
    change_table :orders do |t|
      t.boolean :confirmed
      t.boolean :paid
      t.boolean :packaged
      t.boolean :posted
    end
    
    change_table :orders_copies do |t|
      t.boolean :ticked
    end
  end
end
