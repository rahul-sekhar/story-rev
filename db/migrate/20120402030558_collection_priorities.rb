class CollectionPriorities < ActiveRecord::Migration
  def up
    tables = %w[product_types authors publishers illustrators award_types]
    
    tables.each do |x|
    
      change_table x do |t|
        t.integer :priority, :default => 0
      end
      add_index x, :priority
      
    end
  end
  
  def down
    tables = %w[product_types authors publishers illustrators award_types]
    
    tables.each do |x|
    
      remove_index x, :priority
      
      change_table x do |t|
        t.remove :priority
      end
      
    end
  end
end
