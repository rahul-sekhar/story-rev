require 'spec_helper'

describe Book do
  let!(:book) { build(:book) }
  subject { book }

  it { should be_valid }

  describe "title" do
    context "with a nil title" do
      before { subject.title = nil }
      it { should be_invalid }
    end

    context "with a blank title" do
      before { subject.title = "" }
      it { should be_invalid }
    end

    it "should have a max length of 255 characters" do
      book.title = "a" * 255
      book.should be_valid
      book.title = "a" * 256
      book.should be_invalid
      book.errors[:title].should be_present
    end

    it "should be unique" do
      book.title = "Duplicate Test"
      book.should be_valid
      create(:book, :title => "Duplicate Test")
      book.should be_invalid
      book.errors[:title].should be_present
    end
  end

  it "should require an author" do
    book.author = nil
    book.should be_invalid
    book.errors[:author].should be_present
  end

  it "should ensure that the from age is a number ranging from 0 to 99" do
    ["as", 'a', '-', '1a', 'a1', -1, 100, 1.5, 0.1].each do |x|
      book.age_from = x
      book.should be_invalid
      book.errors[:age_from].should be_present
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
      book.errors[:age_to].should be_present
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
      book.errors[:year].should be_present
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
    book.errors[:amazon_url].should be_present
  end

  describe "accession id" do
    it "should be generated after a book is saved" do
      book.accession_id.should be_nil
      book.save
      book.accession_id.should be_a Integer
    end

    it "should be unique for each new book" do
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
      book.accession_id = 765
      book.save
      book.accession_id.should == 765
    end

    it "should check for uniqueness when user set" do
      book.save
      book2 = build(:book, accession_id: book.accession_id)
      book2.should be_invalid
      book2.errors[:accession_id].should be_present
    end

    it "should reset the accession_id when the user sets it to be nil" do
      book.accession_id = 99
      book.save
      book.accession_id = nil
      book.save
      book.accession_id.should == 100
    end

    it "should reset the accession_id when the user sets it to be a blank string" do
      book.accession_id = 99
      book.save
      book.accession_id = ""
      book.save
      book.accession_id.should == 100
    end

    it "should accept only non-negative integers for user set values" do
      [-1, "a", "1a", "1-", "-", "1_1", 0.56, "1.5"].each do |x|
        book.accession_id = x
        book.should be_invalid, x
        book.errors[:accession_id].should be_present
      end

      [0, 1, 1001, "1"].each do |x|
        book.accession_id = x
        book.should be_valid, x
      end
    end
  end

  it "should set the from age to the to age if only the to age is set" do
    book.age_to = 12
    book.save
    book.age_from.should == 12
  end

  
  [:author, :illustrator, :publisher, :country, :book_type].each do |field|
    it "should check for an invalid #{field}" do
      book.send("#{field}=", build(field))
      book.send(field).stub(:valid?).and_return(false)
      book.should be_invalid
      book.errors[field].should be_present
    end
  end

  it "should add an error for an invalid author name" do
    book.author = build(:author, :name => "a" * 255)
    book.should be_invalid
    book.errors[:author_name].should be_present
  end

  it "should initially be out of stock" do
    book.in_stock.should == false
  end

  it "should return the authors full name as author name" do
    book.author.name = "Test A Name"
    book.author_name.should == "Test A Name"
  end

  it "should use an existing author if one is present with the set author name" do
    author = create(:author, :name => "Existing Author")
    book.author_name = "Existing Author"
    book.author_id.should == author.id
  end

  it "should create a new author if the set author name does not exist" do
    expect do
      book.author_name = "New Author"
      book.save
    end.to change{ Author.count }.by(1)
  end

  it "should use an existing illustrator if one is present with the set illustrator name" do
    illustrator = create(:illustrator, :name => "Existing Illustrator")
    book.illustrator_name = "Existing Illustrator"
    book.illustrator_id.should == illustrator.id
  end

  it "should create a new illustrator if the set illustrator name does not exist" do
    expect do
      book.illustrator_name = "New Illustrator"
     book.save 
   end.to change{ Illustrator.count }.by(1)
  end

  it "should use an existing publisher if one is present with the set publisher name" do
    publisher = create(:publisher, :name => "Existing Publisher")
    book.publisher_name = "Existing Publisher"
    book.publisher_id.should == publisher.id
  end

  it "should create a new publisher if the set publisher name does not exist" do
    expect do
      book.publisher_name = "New Publisher"
      book.save 
    end.to change{ Publisher.count }.by(1)
  end

  it "should use an existing country if one is present with the set country name" do
    country = create(:country, :name => "Existing Country")
    book.country_name = "Existing Country"
    book.country_id.should == country.id
  end

  it "should create a new country if the set country name does not exist" do
    expect do 
      book.country_name = "New Country"
      book.save 
    end.to change{ Country.count }.by(1)
  end

  describe "collections" do
    before do
      ["collection1", "test-collection", "Test two"].each do |name|
        book.collections << create(:collection, :name => name)
      end
    end

    it "should take a comma separated list of collections and use existing objects and create new ones if required, ignoring duplicates" do
      create(:collection, :name => "Test")
      create(:collection, :name => "Test 2")
      create(:collection, :name => "Testing Again")

      expect do
        book.collection_list = "Collection1, Test two, Test, Test 2, Testing Again,New Collection,New,Test, New, new collection"
        book.save
      end.to change{ Collection.count }.by(2)

      book.collections.length.should == 7
    end

    it "should return a comma seperated list of collection names" do
      book.collection_list.should == "collection1, test-collection, Test two"
    end

    it "should check if the book is in a particular collection" do
      book.save
      book.should be_in_collection "test-collection"
      book.should be_in_collection "test two"
      book.should_not be_in_collection "test three"
      new_collection = create(:collection, :name => "Test")
      book.should_not be_in_collection "Test"
      book.should_not be_in_collection new_collection
      book.should be_in_collection Collection.find_by_name("Test two")
    end
  end

  it "should be able to cycle through the books using next book and previous book" do
    (1..4).each do |n|
      create(:book, :title => "Book #{n}")
    end
    last = Book.last
    last.next_book.title.should == "Book 1"
    last.next_book.next_book.title.should == "Book 2"
    last.previous_book.title.should == "Book 3"
    last.previous_book.previous_book.title.should == "Book 2"
  end

  describe "award attributes" do
    it "should allow adding awards" do
      expect do
        book.award_attributes = [{ :award_id => create(:award).id, :year => 2000 }, { :award_id => create(:award).id, :year => 2010 }]
        book.save
      end.to change{ BookAward.count }.by(2)
      book.book_awards.count.should == 2
    end

    it "should allow awards to be edited" do
      book_award = create(:book_award)
      book.book_awards << book_award
      book.save
      award = create(:award)
      book.award_attributes = [{ :id => book_award.id, :year => 1990, :award_id => award.id }]
      book.save
      book_award.reload.year.should == 1990
      book_award.award.should == award
    end

    it "should allow awards to be removed by removing the award id" do
      book_award = create(:book_award)
      book.book_awards << book_award
      book.save

      expect do
        book.award_attributes = [{ :id => book_award.id }]
        book.save
      end.to change{ BookAward.count }.by(-1)
      book.book_awards.count.should == 0
    end
  end

  describe "descriptions" do
    it "should allow adding descriptions" do
      expect do
        book.description_attributes = [attributes_for(:description), attributes_for(:description)]
        book.save
      end.to change{ Description.count }.by(2)
      book.descriptions.count.should == 2
    end

    it "should allow descriptions to be edited" do
      description = create(:description)
      book.descriptions << description
      book.save
      description = create(:description)
      book.description_attributes = [{ :id => description.id, :title => "Changed Title", :content => "Changed Content" }]
      book.save
      description.reload.title.should == "Changed Title"
      description.content.should == "Changed Content"
    end

    it "should allow descriptions to be removed by removing the title" do
      description = create(:description)
      book.descriptions << description
      book.save

      expect do
        book.description_attributes = [{ :id => description.id }]
        book.save
      end.to change{ Description.count }.by(-1)
      book.descriptions.count.should == 0
    end
  end

  describe "cover image" do
    it "should load a cover image from a remote url", :skip do            # Skipped as this test requires the 
      expect do
        book.cover_image_url = "http://localhost:3000/images/title.png"
        book.save
      end.to change{ CoverImage.count }.by(1)
    end

    it "should destroy an existing cover image if a new one is loaded from a url", :skip do
      book.cover_image = create(:cover_image)
      old_id = book.cover_image.id
      book.cover_image_url = "http://localhost:3000/images/title.png"
      book.save
      CoverImage.count.should == 1
      expect { CoverImage.find(old_id) }.to raise_exception
    end

    it "should destroy an existing cover image if a new object is chosen" do
      book.cover_image = create(:cover_image)
      old_id = book.cover_image.id
      new_cover_image = create(:cover_image)
      CoverImage.count.should == 2
      book.cover_image_id = new_cover_image.id
      CoverImage.count.should == 1
      expect { CoverImage.find(old_id) }.to raise_exception
    end
  end

  describe "copies" do
    before do
      book.editions << build_list(:edition, 4)
      book.save
    end

    it "should show the right number of copies" do
      book.editions[0].used_copies << build_list(:used_copy, 2)
      book.editions[0].used_copies << build(:used_copy, set_stock: 0)
      book.editions[0].new_copies << build(:new_copy, stock: 3)

      book.editions[1].used_copies << build_list(:used_copy, 2, set_stock: 0)
      book.editions[1].used_copies << build_list(:used_copy, 4)

      book.editions[2].used_copies << build_list(:used_copy, 2, set_stock: 0)
      book.editions[2].new_copies << build_list(:new_copy, 3)

      book.editions[3].new_copies << build_list(:new_copy, 2, stock: 10)
      book.editions[3].new_copies << build_list(:new_copy, 3)

      book.number_of_copies.should == 29
    end

    it "should correctly find the used copy minimum price" do
      book.editions[0].used_copies << build_list(:used_copy, 3, price: 60)
      book.editions[1].used_copies << build(:used_copy, price: 30)
      book.editions[1].used_copies << build(:used_copy, price: 20, set_stock: 0)
      book.editions[1].new_copies << build(:new_copy, price: 25, set_stock: 5)
      book.editions[2].used_copies << build(:used_copy, price: 40)
      book.used_copy_min_price.should == 30
    end

    it "should correctly find the new copy minimum price" do
      book.editions[0].new_copies << build(:new_copy, price: 45, set_stock: 6)
      book.editions[2].used_copies << build(:used_copy, price: 30)
      book.editions[2].new_copies << build(:new_copy, price: 40, set_stock: 3)
      book.editions[2].new_copies << build(:new_copy, price: 35)
      book.new_copy_min_price.should == 40
    end
  end

  describe "after being destroyed" do
    it "should destroy child editions" do
      book.editions << build_list(:edition, 2)
      book.save
      expect{ book.destroy }.to change{ Edition.count }.by(-2)
    end

    it "should destroy awards" do
      book.book_awards << build_list(:book_award, 2)
      book.save
      expect{ book.destroy }.to change{ BookAward.count }.by(-2)
    end

    it "should destroy the cover image" do
      book.cover_image = build(:cover_image)
      book.save
      expect{ book.destroy }.to change{ CoverImage.count }.by(-1)
    end

    it "should destroy descriptions" do
      book.descriptions << build_list(:description, 2)
      book.save
      expect{ book.destroy }.to change{ Description.count }.by(-2)
    end
  end
end