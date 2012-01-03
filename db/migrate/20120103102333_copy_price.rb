class CopyPrice < ActiveRecord::Migration
  def change
    change_table :copies do |t|
      t.integer :price
    end
  end
end
