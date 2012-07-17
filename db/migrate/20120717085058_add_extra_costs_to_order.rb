class AddExtraCostsToOrder < ActiveRecord::Migration
  def change
    create_table :extra_costs do |t|
      t.integer :order_id
      t.integer :amount
      t.string :name
      t.timestamps
    end

    add_index :extra_costs, :order_id
  end
end
