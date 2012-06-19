class OtherFieldsToDescriptions < ActiveRecord::Migration
  def up
    rename_table :other_fields, :descriptions
  end

  def down
    rename_table :descriptions, :other_fields
  end
end
