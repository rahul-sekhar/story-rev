class EnglishHardcodedAsDefaultLanguage < ActiveRecord::Migration
  def up
    change_column_default :editions, :language_id, nil

    Edition.where(language_id: 1).each do |x|
      x.language_id = nil
      x.save
    end

    Language.find(1).destroy
  end

  def down
    lang = Language.new(name: "English")
    lang.id = 1
    lang.save
    SqlHelper.reset_primary_key(Language)

    Edition.where(language_id: nil).each do |x|
      x.language_id = 1
      x.save
    end

    change_column_default :editions, :language_id, 1
  end
end
