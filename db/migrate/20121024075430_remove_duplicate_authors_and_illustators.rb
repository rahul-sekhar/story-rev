class RemoveDuplicateAuthorsAndIllustators < ActiveRecord::Migration
  def up
    a = DuplicateNames::Handler.new(Author, :books, true)
    a.merge_duplicates

    i = DuplicateNames::Handler.new(Illustrator, :books, true)
    i.merge_duplicates

    puts "\t\n\n*** REMEMBER TO CHECK FOR DUPLICATE BOOKS ***\n\n"
  end

  def down
  end
end
