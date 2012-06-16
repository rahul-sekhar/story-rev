class RefactorCopies < ActiveRecord::Migration
  class Copy < ActiveRecord::Base
  end
  
  def up
    Copy.reset_column_information
    
    # Set new copies to have a condition rating of 5
    Copy.all.each do |x|
      if x.new_copy
        x.condition_rating = 5
      else
        # The 'stock' field (earlier 'number') now handles whether a copy is seen as 'in stock' or not.
        # Change it for used copies depending on the old 'in_stock' field
        x.number = x.in_stock ? 1 : 0
      end
      x.save
    end
    
    change_table :copies do |t|
      t.rename :number, :stock
      t.integer :required_stock
      t.remove :limited_copies, :in_stock
    end
  end
  
  def down
    change_table :copies do |t|
      t.rename :stock, :number
      t.remove :required_stock
      t.boolean :limited_copies
      t.boolean :in_stock
    end
  end
end
