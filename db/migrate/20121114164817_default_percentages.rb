class DefaultPercentages < ActiveRecord::Migration
  def up
    change_table :config_data do |t|
      t.integer :default_percentage, null: false, default: 0
    end

    create_table :default_percentages do |t|
      t.integer :publisher_id, null: false
      t.integer :percentage, null: false, default: 0
    end

    add_index :default_percentages, :publisher_id, unique: true
  end

  def down
    drop_table :default_percentages

    change_table :config_data do |t|
      t.remove :default_percentage
    end
  end
end
