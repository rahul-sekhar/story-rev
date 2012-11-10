class RefactorOrders < ActiveRecord::Migration
  def up
    create_table :customers do |t|
      t.integer :order_id, null: false
      t.timestamps
    end

    add_index :customers, :order_id

    change_table :orders do |t|
      
    end

    add_index :ordrers_copies, :order_id
    add_index :ordrers_copies, :copy_id

    drop_table :shopping_carts, :shopping_carts_copies
  end

  def down
    drop_table :customers

    change_table :orders do |t|

    end

    create_table :shopping_carts do |t|
      t.timestamps
    end

    add_index :shopping_carts, :updated_at

    create_table :shopping_carts_copies do |t|
      t.integer :shopping_cart_id, null: false
      t.integer :copy_id, null: false
      t.integer :number
    end

    add_index :shopping_carts_copies, :shopping_cart_id
    add_index :shopping_carts_copies, :copy_id
  end
end
