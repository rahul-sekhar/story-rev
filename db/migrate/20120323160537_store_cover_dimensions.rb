class StoreCoverDimensions < ActiveRecord::Migration
  def change
    change_table :cover_images do |t|
      t.integer :medium_width
      t.integer :medium_height
    end
  end
end
