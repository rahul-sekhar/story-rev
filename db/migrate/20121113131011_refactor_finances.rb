class RefactorFinances < ActiveRecord::Migration
  def up
    # Transfers tables
    drop_table :transfers
    drop_table :transfer_categories

    # Accounts table
    change_table :accounts do |t|
      t.change :name, :string, null: false, limit: 120

      t.integer :share, null: false, default: 0
    end

    remove_index :accounts, :name
    add_index :accounts, :name, unique: true
    add_index :accounts, :share

    # Account profit shares table
    create_table :account_profit_shares do |t|
      t.integer :account_id, null: false
      t.integer :order_id, null: false
      t.integer :amount, null: false
      t.timestamps
    end

    add_index :account_profit_shares, :account_id
    add_index :account_profit_shares, :order_id
    add_index :account_profit_shares, [:order_id, :account_id]
    add_index :account_profit_shares, :created_at

    # Loans table
    create_table :loans do |t|
      t.integer :amount, null: false
      t.string :name, limit: 200
      t.timestamps
    end

    add_index :loans, :name
    add_index :loans, :amount
    add_index :loans, :created_at

    # Config data
    change_table :config_data do |t|
      t.remove :default_account_id, :cash_account_id
    end

    # Extra costs
    change_table :extra_costs do |t|
      t.change :order_id, :integer, null: false
      t.change :amount, :integer, null: false
      t.change :name, :string, null: false, limit: 255

      t.integer :expenditure, null: false, default: 0
    end

    # Transaction categories
    change_table :transaction_categories do |t|
      t.change :name, :string, null: false, limit: 120
      
      t.remove :off_record
    end

    remove_index :transaction_categories, :name
    add_index :transaction_categories, :name, unique: true

    # Transactions
    change_table :transactions do |t|
      t.change :credit, :integer, null: false, default: 0
      t.change :debit, :integer, null: false, default: 0
      t.change :other_party, :string, limit: 200
      t.change :transaction_category_id, :integer, null: false
      t.change :date, :datetime, null: false

      t.remove :account_id, :off_record
    end
  end

  def down
  end
end
