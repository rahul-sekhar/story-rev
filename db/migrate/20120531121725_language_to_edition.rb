class LanguageToEdition < ActiveRecord::Migration
  def change
    change_table :products do |t|
      t.remove :language_id
    end
    
    change_table :editions do |t|
      t.integer :language_id, :default => 1
    end
  end
end
