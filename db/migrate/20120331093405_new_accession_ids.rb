class NewAccessionIds < ActiveRecord::Migration
  def change
    remove_column :authors, :accession_id
    
    change_table :products do |t|
      t.remove :accession_id
      t.integer :accession_id
    end
    
    add_index :products, :accession_id
    
    change_table :copies do |t|
      t.integer :copy_number
    end
    
    add_index :copies, :copy_number
  end
end
