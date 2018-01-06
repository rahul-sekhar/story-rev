class AddDiscountField < ActiveRecord::Migration
  def up
    add_column :config_data, :discount_percentage, :integer, default: 0, null: false
    add_column :orders, :discount_percentage, :integer, default: 0, null: false
  end

  def down
    remove_column :config_data, :discount_percentage
    remove_column :orders, :discount_percentage
  end
end
