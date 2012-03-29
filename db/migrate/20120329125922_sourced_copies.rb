class SourcedCopies < ActiveRecord::Migration
  def change
    create_table :new_copies do |t|
      t.integer :edition_id
      
      t.timestamps
    end
  end
end
