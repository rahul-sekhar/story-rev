class ThemeTimestamps < ActiveRecord::Migration
  def change
    change_table :themes do |t|
      t.timestamps
    end
    
    change_table :theme_icons do |t|
      t.timestamps
    end
  end
end
