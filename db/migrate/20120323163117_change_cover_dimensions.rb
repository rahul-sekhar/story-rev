class ChangeCoverDimensions < ActiveRecord::Migration
  def change
    change_table :cover_images do |t|
      t.rename :medium_width, :width
      t.rename :medium_height, :height
    end
  end
end
