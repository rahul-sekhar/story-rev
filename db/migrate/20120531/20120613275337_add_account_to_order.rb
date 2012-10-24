class AddAccountToOrder < ActiveRecord::Migration
  def up
    change_table :orders do |t|
      t.integer :account_id
    end
  end

  def down
    change_table :orders do |t|
      t.remove :account_id
    end
  end
end
