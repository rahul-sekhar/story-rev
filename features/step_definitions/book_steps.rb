Then /^a book should exist with the title "(.*?)"$/ do |arg1|
  @book = Book.find_by_title(arg1)
  @book.should be_present
end

Then /^a book should not exist with the title "(.*?)"$/ do |arg1|
  Book.find_by_title(arg1).should be_nil
end

Then /^that book should have the following attributes$/ do |table|
  table.rows_hash.each do |key, val|
    @book.send(key).to_s.should == val
  end
end

Then /^that book should have a collection with the name "(.*?)"$/ do |arg1|
  @book.collections.find_by_name(arg1).should be_present
end

Then /^that book should have an award with the name "(.*?)"$/ do |arg1|
  @book.book_awards.to_a.count{ |x| x.full_name == arg1 }.should == 1
end

Then /^that book should have a description with the title "(.*?)" and content "(.*?)"$/ do |title, content|
  @book.descriptions.to_a.count{ |x| x.title == title && x.content == content }.should == 1
end

Given /^an award exists with the type "(.*?)" and the name "(.*?)"$/ do |type, name|
  award_type = AwardType.create(name: type)
  Award.create(name: name, award_type_id: award_type.id)
end

Then /^that book should have a cover image$/ do
  @book.cover_image.should be_present
end

Given /^a book exists with information:$/ do |table|
  @book = Book.create(table.rows_hash)
end