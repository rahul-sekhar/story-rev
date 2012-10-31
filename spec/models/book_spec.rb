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

    it "should be case insensitively unique" do
      book.title = "Duplicate Test"
      book.should be_valid
      create(:book, :title => "duplicate TEST")
      book.should be_invalid
      book.errors[:title].should be_present
    end

    it "should be unique even with extra trailing and leading spaces" do
      book.title = "    Duplicate Test   "
      book.should be_valid
      create(:book, :title => "duplicate test")
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
    ['a', '-', '1a', -1, 100, 1.5].each do |x|
      book.age_from = x
      book.should be_invalid
      book.errors[:age_from].should be_present
    end
    [0,7,99].each do |x|
      book.age_from = x
      book.should be_valid
    end
  end

  it "should ensure that the to age is a number ranging from 0 to 99" do
    ['a', '-', '1a', -1, 100, 1.5].each do |x|
      book.age_to = x
      book.should be_invalid, x
      book.errors[:age_to].should be_present
    end
    [0,7,99].each do |x|
      book.age_to = x
      book.should be_valid, x
    end
  end

  it "should ensure that the publication year is a number ranging from 1000 to 2099" do
    ['a', '-', '1a', 2100, 1.5, 999].each do |x|
      book.year = x
      book.should be_invalid, x
      book.errors[:year].should be_present
    end
    [1000,2000,2099].each do |x|
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
      book.accession_id.should > 0
    end

    it "should increment for each new book" do
      book1 = create(:book)
      book2 = create(:book)
      book2.accession_id.should == book1.accession_id + 1
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

    it "should check for uniqueness when set by the user" do
      book.save
      book2 = build(:book, accession_id: book.accession_id)
      book2.should be_invalid
      book2.errors[:accession_id].should be_present
    end

    it "should reset the accession_id when the user sets it to be blank" do
      book.accession_id = 99
      book.save
      book.accession_id = ""
      book.save
      book.accession_id.should == 100
    end

    it "should accept only non-negative integers for user set values" do
      [-1, "a", "1a", "-", 0.56, "1.5"].each do |x|
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

  describe "#author_name" do
    let(:object) { "author" }
    let(:klass) { Author }
    it_should_behave_like "object tagged by name"
  end

  describe "#illustrator_name" do
    let(:object) { "illustrator" }
    let(:klass) { Illustrator }
    it_should_behave_like "object tagged by name"
  end

  describe "#publisher_name" do
    let(:object) { "publisher" }
    let(:klass) { Publisher }
    it_should_behave_like "object tagged by name"
  end

  describe "#country_name" do
    let(:object) { "country" }
    let(:klass) { Country }
    it_should_behave_like "object tagged by name"
  end

  describe "collections" do
    it "should return a comma separated list of the collection names" do
      ["Collection 1", "Collection 2", "Collection 3"].each do |x|
        book.collections << Collection.new(name: x)
      end
      book.collection_list.should == "Collection 1, Collection 2, Collection 3"
    end

    it "should split a received list of collection names into a collection array" do
      Collection.should_receive(:from_list){[]}.with("List, of, Collections")
      book.collection_list = "List, of, Collections"
    end
  end

  it "should be able to cycle through the books using next book and previous book" do
    (1..3).each do |n|
      create(:book, :title => "Book #{n}")
    end
    last = Book.find_by_title("Book 3")
    last.next_book.title.should == "Book 1"
    last.next_book.next_book.title.should == "Book 2"
    last.previous_book.title.should == "Book 2"
    last.previous_book.previous_book.title.should == "Book 1"
    last.previous_book.previous_book.previous_book.title.should == "Book 3"
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
    it "should load a cover image from a remote url", :server do
      expect do
        book.cover_image_url = "http://localhost:3000/images/title.png"
        book.save
      end.to change{ CoverImage.count }.by(1)
    end

    it "should destroy an existing cover image if a new one is loaded" do
      old_cover = CoverImage.new
      old_cover.should_receive(:destroy)
      book.cover_image = old_cover
      book.cover_image = CoverImage.new
    end

    it "should load a cover image by ID" do
      new_cover = CoverImage.new
      CoverImage.should_receive(:find).with(50).and_return(new_cover)
      book.cover_image_id = 50
      book.cover_image.should equal(new_cover)
    end
  end

  describe "copies" do
    before :each do
      book.editions << build_list(:edition, 2)
      book.save
    end

    it "should show the right number of copies" do
      book.editions[0].used_copies << build_list(:used_copy, 2)
      book.editions[0].used_copies << build(:used_copy, stock: 0)
      book.editions[0].new_copies << build(:new_copy, stock: 3)

      book.editions[1].new_copies << build_list(:new_copy, 2, stock: 10)
      book.editions[1].new_copies << build(:new_copy)

      book.number_of_copies.should == 25
    end

    it "should correctly find the used copy minimum price" do
      book.editions[0].used_copies << build(:used_copy, price: 60)
      book.editions[0].new_copies << build(:new_copy, price: 25, stock: 5)
      book.editions[1].used_copies << build(:used_copy, price: 30)
      book.editions[1].used_copies << build(:used_copy, price: 20, stock: 0)
      book.used_copy_min_price.should == 30
    end

    it "should correctly find the new copy minimum price" do
      book.editions[0].new_copies << build(:new_copy, price: 45, stock: 6)
      book.editions[1].used_copies << build(:used_copy, price: 30)
      book.editions[1].new_copies << build(:new_copy, price: 40, stock: 3)
      book.editions[1].new_copies << build(:new_copy, price: 35)
      book.new_copy_min_price.should == 40
    end
  end

  describe "after being destroyed" do
    it "should destroy child editions" do
      book.editions << build(:edition)
      book.save
      expect{ book.destroy }.to change{ Edition.count }.by(-1)
    end

    it "should destroy awards" do
      book.book_awards << build(:book_award)
      book.save
      expect{ book.destroy }.to change{ BookAward.count }.by(-1)
    end

    it "should destroy the cover image" do
      book.cover_image = build(:cover_image)
      book.save
      expect{ book.destroy }.to change{ CoverImage.count }.by(-1)
    end

    it "should destroy descriptions" do
      book.descriptions << build(:description)
      book.save
      expect{ book.destroy }.to change{ Description.count }.by(-1)
    end
  end
end