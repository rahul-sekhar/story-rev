class CombineThemesAndKeywords < ActiveRecord::Migration
  def change
    rename_table :keywords, :collections
    rename_table :products_keywords, :products_collections
    
    drop_table :themes
    drop_table :products_themes
  end
end
