class AddCostPrice < ActiveRecord::Migration
  def up
    change_table :copies do |t|
      t.integer :cost_price, null: false, default: 0
    end

    create_table :default_cost_prices do |t|
      t.integer :book_type_id, null: false
      t.integer :format_id, null: false
      t.integer :cost_price, null: false, default: 0
      t.timestamps
    end

    add_index :default_cost_prices, [:book_type_id, :format_id], unique: true

    change_table :config_data do |t|
      t.integer :default_cost_price, null: false, default: 0
    end

  end

  def down
    change_table :copies do |t|
      t.remove :cost_price
    end

    change_table :config_data do |t|
      t.remove :default_cost_price
    end

    drop_table :default_cost_prices
  end
end
