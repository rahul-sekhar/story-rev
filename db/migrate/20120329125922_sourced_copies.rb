class SourcedCopies < ActiveRecord::Migration
  def change
    create_table :new_copies do |t|
      t.integer :edition_id
      t.boolean :limited_copies
      t.integer :number
      t.integer :price
      
      t.timestamps
    end
  end
end
