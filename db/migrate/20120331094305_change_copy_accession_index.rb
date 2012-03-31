class ChangeCopyAccessionIndex < ActiveRecord::Migration
  def change
    remove_index :copies, :accession_id
    add_index :copies, :accession_id
  end
end
