class CreateFinancesTables < ActiveRecord::Migration
  class Order < ActiveRecord::Base
  end
  
  def change
    change_table :orders do |t|
      t.remove :postage_expenditure
      t.rename :payment_method, :payment_method_id
      
      t.datetime  :confirmed_date
      t.datetime  :paid_date
      t.datetime  :packaged_date
      t.datetime  :posted_date
      t.integer :postage_transaction_id
      t.integer :transaction_id
    end
    add_index :orders, :confirmed_date
    add_index :orders, :paid_date
    add_index :orders, :postage_transaction_id
    add_index :orders, :transaction_id
    
    Order.reset_column_information
    Order.all.each do |o|
      o.confirmed_date = o.created_at if o.confirmed
      o.paid_date = o.created_at if o.paid
      o.packaged_date = o.created_at if o.packaged
      o.posted_date = o.created_at if o.posted
      o.save
    end
    
    change_table :orders do |t|
      t.remove :confirmed, :paid, :packaged, :posted
    end
    
    create_table :transactions do |t|
      t.integer :credit
      t.integer :debit
      t.string :other_party
      t.integer :payment_method_id
      t.integer :transaction_category_id
      t.integer :account_id
      t.boolean :off_record, :default => false
      t.datetime :date
      t.text :notes
      t.timestamps
    end
    add_index :transactions, :other_party
    add_index :transactions, :date
    add_index :transactions, :off_record
    add_index :transactions, :account_id
    add_index :transactions, :payment_method_id
    add_index :transactions, :transaction_category_id
    
    
    create_table :payment_methods do |t|
      t.string :name
      t.timestamps
    end
    add_index :payment_methods, :name
    
    
    create_table :transaction_categories do |t|
      t.string :name
      t.boolean :off_record, :default => false
      t.timestamps
    end
    add_index :transaction_categories, :name
    
    
    create_table :accounts do |t|
      t.string :name
      t.timestamps
    end
    add_index :accounts, :name
    
    
    create_table :config_data do |t|
      t.integer :default_account_id
      t.integer :cash_account_id
    end
  end
end
