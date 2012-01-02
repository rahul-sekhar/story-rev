class RawIsbn < ActiveRecord::Migration
  def change
    change_table :editions do |t|
      t.string :raw_isbn
    end
  end
end
