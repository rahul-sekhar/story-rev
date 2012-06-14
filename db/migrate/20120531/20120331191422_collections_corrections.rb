class CollectionsCorrections < ActiveRecord::Migration
  def change
    change_table :products_collections do |t|
      t.rename :keyword_id, :collection_id
    end
    
    change_table :collections do |t|
      t.integer :priority, :default => 0
    end
  end
end
