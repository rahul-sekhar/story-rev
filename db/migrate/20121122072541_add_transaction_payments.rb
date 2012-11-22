class AddTransactionPayments < ActiveRecord::Migration
  def up
    change_table :transactions do |t|
      t.integer :account_id
    end

    add_index :transactions, :account_id
  end

  def down
    change_table :transactions do |t|
      t.remove :account_id
    end
  end
end
