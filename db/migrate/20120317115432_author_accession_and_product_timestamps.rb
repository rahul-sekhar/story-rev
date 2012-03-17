class AuthorAccessionAndProductTimestamps < ActiveRecord::Migration
  def change
    change_table :authors do |t|
      t.string :accession_id
    end
    
    add_index :authors, :accession_id, :unique => true
    
    change_table :products do |t|
      t.datetime :in_stock_date
      t.datetime :out_of_stock_date
      t.datetime :book_date
    end
    
    add_index :products, :book_date
  end
end
