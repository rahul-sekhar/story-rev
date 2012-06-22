require 'spec_helper'
require '/home/rahul/projects/story-rev/app/models/book'

describe Book do
  let(:book) { build(:book) }

  it "should begin with a valid book" do
    book.should be_valid
  end

  describe "title" do
    it "should not be nil" do
      book.title = nil
      book.should be_invalid
    end

    it "should not be blank" do
      book.title = ""
      book.should be_invalid
    end

    it "should have a max length of 255 characters" do
      book.title = "a" * 255
      book.should be_valid
      book.title = "a" * 256
      book.should be_invalid
    end

    it "should be unique" do
      book.title = "Duplicate Test"
      book.should be_valid
      create(:book, :title => "Duplicate Test")
      book.should be_invalid
    end
  end

  it "should require an author" do
    book.author = nil
    book.should be_invalid
  end



  it "should ensure that the from age is a number ranging from 0 to 99" do
    ["as", 'a', '-', '1a', 'a1', -1, 100, 1.5, 0.1].each do |x|
      book.age_from = x
      book.should be_invalid
    end
    [0,1,7,99].each do |x|
      book.age_from = x
      book.should be_valid
    end
  end

  it "should ensure that the to age is a number ranging from 0 to 99" do
    ["as", 'a', '-', '1a', 'a1', -1, 100].each do |x|
      book.age_to = x
      book.should be_invalid, x
    end
    [0,1,7,99].each do |x|
      book.age_to = x
      book.should be_valid, x
    end
  end

  it "should ensure that the publication year is a number ranging from 1000 to 2099" do
    ["as", 'a', '-', '1a', 'a1', -1, 2100, 1.5, 999].each do |x|
      book.year = x
      book.should be_invalid, x
    end
    [1000,1999,2000,2099].each do |x|
      book.year = x
      book.should be_valid, x
    end
  end

  it "should check the length of the amazon url" do
    book.amazon_url = "a" * 255
    book.should be_valid
    book.amazon_url = "a" * 256
    book.should be_invalid
  end

  describe "accession id" do
    it "should be generated after a book is saved" do
      book.accession_id.should be_nil
      book.save
      book.accession_id.should be_a Integer
    end

    it "should be unique" do
      book1 = create(:book)
      book2 = create(:book)
      book1.accession_id.should_not == book2.accession_id
    end

    it "should not change on save unless changed manually" do
      book.save
      old_accession_id = book.accession_id
      book.title = "Changed title"
      book.save
      book.accession_id.should == old_accession_id
      book.accession_id = old_accession_id + 1
      book.save
      book.accession_id.should == old_accession_id + 1
    end

    it "should be settable before saving" do
      book.accession_id = 99
      book.save
      book.accession_id.should == 99
    end
  end
  
  [:author, :illustrator, :publisher, :country, :book_type].each do |field|
    it "should check for an invalid #{field}" do
      book.send("#{field}=", build(field))
      book.send(field).stub(:valid?).and_return(false)
      book.should be_invalid
    end
  end

end