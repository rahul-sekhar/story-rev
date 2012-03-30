class FixIsbnBug < ActiveRecord::Migration
  def change
    remove_index :editions, :isbn
    add_index :editions, :isbn
    add_index :editions, :raw_isbn
  end
end
