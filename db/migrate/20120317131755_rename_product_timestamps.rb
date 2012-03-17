class RenameProductTimestamps < ActiveRecord::Migration
  def change
    change_table :products do |t|
      t.rename :in_stock_date, :in_stock_at
      t.rename :out_of_stock_date, :out_of_stock_at
    end
  end
end
