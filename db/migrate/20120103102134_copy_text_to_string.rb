class CopyTextToString < ActiveRecord::Migration
  def up
    change_table :copies do |t|
      t.change :condition_description, :string
    end
  end

  def down
    change_table :copies do |t|
      t.change :condition_description, :text
    end
  end
end
