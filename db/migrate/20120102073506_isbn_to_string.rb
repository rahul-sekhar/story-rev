class IsbnToString < ActiveRecord::Migration
  def up
    change_table :editions do |t|
      t.change :isbn, :string
    end
  end

  def down
    t.change :isbn, :integer
  end
end
