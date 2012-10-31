class RemoveInvalidData < ActiveRecord::Migration
  def up
    a = DuplicateNames::Handler.new(Author, :books, true)
    a.merge_duplicates

    i = DuplicateNames::Handler.new(Illustrator, :books, true)
    i.merge_duplicates

    puts "\t\n\n*** REMEMBER TO CHECK FOR DUPLICATE BOOKS ***\n\n"

    puts "Removing invalid or duplicate email addresses:"
    EmailSubscription.all.each do |x|
      if x.invalid?
        puts "\t-#{x.email}"
        x.destroy
      end
    end
  end

  def down
  end
end
