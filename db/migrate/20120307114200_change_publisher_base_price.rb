class ChangePublisherBasePrice < ActiveRecord::Migration
  def up
    change_table :products do |t|
      t.remove :publisher_id
    end
    
    change_table :editions do |t|
      t.remove :base_price
      t.integer :publisher_id
    end
  end

  def down
    change_table :products do |t|
      t.integer :publisher_id
    end
    
    change_table :editions do |t|
      t.integer :base_price
      t.remove :publisher_id
    end
  end
end
