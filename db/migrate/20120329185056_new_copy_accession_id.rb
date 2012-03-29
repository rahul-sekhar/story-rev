class NewCopyAccessionId < ActiveRecord::Migration
  def change
    change_table :new_copies do |t|
      t.string :accession_id
    end
    
    add_index :new_copies, :accession_id
  end
end
