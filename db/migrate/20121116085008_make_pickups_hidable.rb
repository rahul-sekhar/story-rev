class MakePickupsHidable < ActiveRecord::Migration
  def up
    change_table :pickup_points do |t|
      t.boolean :visible, null: false, default: true
    end

    add_index :pickup_points, :visible
  end

  def down
    change_table :pickup_points do |t|
      t.remove :visible
    end
  end
end
