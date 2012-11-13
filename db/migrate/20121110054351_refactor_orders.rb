class RefactorOrders < ActiveRecord::Migration
  def up
    # Customers table
    create_table :customers do |t|
      t.integer :order_id, null: false
      t.integer :delivery_method, null: false
      t.integer :pickup_point_id
      t.integer :payment_method_id
      t.text :other_pickup
      t.string :name, limit: 150
      t.string :email, limit: 100
      t.string :phone, limit: 40
      t.text :address
      t.string :city, limit: 40
      t.string :pin_code, limit: 10
      t.text :other_info
      t.text :notes

      t.timestamps
    end

    add_index :customers, :order_id, unique: true
    add_index :customers, :name


    # Orders table
    change_table :orders do |t|
      # Columns moved to the customers table
      t.remove :delivery_method, :pickup_point_id, :payment_method_id, :other_pickup, :name, :email, :phone, :address, :city, :other_info, :pin_code, :notes

      # Removed columns
      t.remove :step, :shopping_cart_id, :postage_transaction_id, :transaction_id, :account_id

      t.boolean :complete, null: false, default: false
    end

    change_column :orders, :postage_amount, :integer, null: false, default: 0
    change_column :orders, :total_amount, :integer, null: false, default: 0

    add_index :orders, :complete


    # Orders-copies table
    change_table :orders_copies do |t|
      t.boolean :final, null: false, default: false
      t.timestamps
    end

    change_column :orders_copies, :order_id, :integer, null: false
    change_column :orders_copies, :copy_id, :integer, null: false
    change_column :orders_copies, :number, :integer, null: false, default: 1
    change_column :orders_copies, :ticked, :boolean, null: false, default: false

    add_index :orders_copies, :order_id
    add_index :orders_copies, :copy_id
    add_index :orders_copies, :updated_at
    add_index :orders_copies, :final


    # Payment methods table
    change_column :payment_methods, :name, :string, null: false, limit: 120
    remove_index :payment_methods, :name
    add_index :payment_methods, :name, unique: true

    # Shopping cart tables
    drop_table :shopping_carts
    drop_table :shopping_carts_copies
  end

  def down
    # Customers table
    drop_table :customers

    # Orders table
    change_table :orders do |t|
      t.integer :delivery_method
      t.integer :pickup_point_id
      t.integer :payment_method_id
      t.text :other_pickup
      t.string :name
      t.string :email
      t.string :phone
      t.text :address
      t.string :city
      t.string :pin_code
      t.text :other_info
      t.integer :step
      t.integer :shopping_cart_id
      t.integer :postage_transaction_id
      t.integer :transaction_id
      t.integer :account_id
      t.text :notes

      t.remove :complete
    end

    change_column :orders, :postage_amount, :integer, null: true
    change_column_default :orders, :postage_amount, nil
    change_column :orders, :total_amount, :integer, null: true, default: 0
    change_column_default :orders, :total_amount, nil


    # Orders-copies table
    change_table :orders_copies do |t|
      t.remove :created_at, :updated_at, :final
    end

    change_column :orders_copies, :order_id, :integer, null: true
    change_column :orders_copies, :copy_id, :integer, null: true
    change_column :orders_copies, :number, :integer, null: true
    change_column_default :orders_copies, :number, nil
    change_column :orders_copies, :ticked, :boolean, null: true
    change_column_default :orders_copies, :ticked, nil

    remove_index :orders_copies, :order_id
    remove_index :orders_copies, :copy_id


    # Payment methods table
    change_column :payment_methods, :name, :string, null: true
    remove_index :payment_methods, :name
    add_index :payment_methods, :name

    # Shopping cart tables
    create_table :shopping_carts do |t|
      t.timestamps
    end

    add_index :shopping_carts, :updated_at

    create_table :shopping_carts_copies do |t|
      t.integer :shopping_cart_id
      t.integer :copy_id
      t.integer :number
    end
  end
end
