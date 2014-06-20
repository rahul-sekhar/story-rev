class StoreOpenButton < ActiveRecord::Migration
  def up
    add_column :config_data, :store_open, :boolean, default: true, null: false
  end

  def down
    remove_column :config_data, :store_open
  end
end
