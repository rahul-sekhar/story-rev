class AddAccountTransfer < ActiveRecord::Migration
  def up

    create_table :transfers do |t|
      t.integer :amount
      t.integer :source_account_id
      t.integer :target_account_id
      t.integer :transfer_category_id
      t.integer :payment_method_id
      t.text :notes
      t.datetime :date
      t.timestamps
    end

    add_index :transfers, :source_account_id
    add_index :transfers, :target_account_id
    add_index :transfers, :transfer_category_id
    add_index :transfers, :payment_method_id
    add_index :transfers, :date
    
    create_table :transfer_categories do |t|
      t.string :name
      t.timestamps
    end

    add_index :transfer_categories, :name

    # Rename the default cash account to 'Unaccounted'
    cash_account = Account.find_by_name("Cash")
    cash_account.name = "Unaccounted"
    cash_account.save

    # Create a transfer category called 'Account Transfer'
    TransferCategory.create(name: 'Account Transfer')
  end

  def down
    drop_table :transfers
    drop_table :transfer_categories

    cash_account = Account.find_by_name("Unaccounted")
    cash_account.name = "Cash"
    cash_account.save
  end
end
