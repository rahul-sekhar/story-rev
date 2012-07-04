class EnglishHardcodedAsDefaultLanguage < ActiveRecord::Migration
  def up
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
    SqlHelper.reset_primary_key(Langauge)

    Edition.where(language_id: nil).each do |x|
      x.language_id = 1
      x.save
    end
  end
end
