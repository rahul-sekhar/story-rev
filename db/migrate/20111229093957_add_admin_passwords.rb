class AddAdminPasswords < ActiveRecord::Migration
  def change
    create_table :admin_roles do |t|
      t.string :name
      t.string :password_hash
      t.string :password_salt
      
      t.timestamps
    end
  end
end
