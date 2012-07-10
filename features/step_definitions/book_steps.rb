Then /^a book should exist with the title "(.*?)"$/ do |arg1|
  @book = Book.find_by_title(arg1)
  @book.should be_present
end

Then /^the book should have the following attributes$/ do |table|
  table.rows_hash.each do |key, val|
    @book.send(key).to_s.should == val
  end
end
