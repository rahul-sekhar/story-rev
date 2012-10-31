require 'spec_helper'

describe UsedCopy do
  let(:copy) { build(:used_copy) }
  let(:unstubbed_copy) { build(:used_copy_with_book) }
  let(:book_stub) { double("book") }
  before do
    copy.stub(:book).and_return(book_stub)
    copy.stub(:set_accession_id) do
      copy.copy_number = 1
      copy.accession_id = "1-1"
    end
    book_stub.stub(:check_stock)
  end

  it_should_behave_like "a copy"

  it "should only retrieve used copies from the database" do
    copy1 = create(:used_copy_with_book)
    copy2 = create(:used_copy_with_book)
    new_copy = create(:new_copy_with_book)
    used_copies = UsedCopy.all
    used_copies.should include(copy1, copy2)
    used_copies.should_not include(new_copy)
  end

  it "should initially be in stock" do
    copy.should be_in_stock
  end

  it "should have new copy set to false" do
    copy.new_copy.should == false
  end

  it "should have a default condition rating of 3" do
    copy.condition_rating.should == 3
  end

  describe "book_date" do
    it "should set the book date when a fresh copy is created" do
      book_stub.should_receive(:set_book_date)
      copy.save
    end

    it "should not set the book date when a fresh copy is created and set to out of stock" do
      book_stub.should_not_receive(:set_book_date)
      copy.stock = 0
      copy.save
    end
    
    it "should not set the book date when a fresh copy is created and goes back in stock" do
      copy.stock = 0
      copy.save
      book_stub.should_not_receive(:set_book_date)
      copy.stock = 1
      copy.save
    end
  end

  it "should check the length of the condition description" do
    copy.condition_description = "a" * 255
    copy.should be_valid
    copy.condition_description = "a" * 256
    copy.should be_invalid
    copy.errors[:condition_description].should be_present
  end

  describe "function to filter unique copies" do
    let (:copy1) { build(:used_copy, edition_id: 1) }
    before do
      copy.edition_id = 1
    end

    it "should filter out copies with the same attributes" do
      copy2 = build(:used_copy, edition_id: 1)
      UsedCopy.filter_unique([copy, copy1, copy2]).should == [copy]
    end

    it "should not filter copies from a different edition" do
      copy2 = build(:used_copy, edition_id: 2)
      UsedCopy.filter_unique([copy, copy1, copy2]).should == [copy, copy2]
    end

    it "should not filter copies with a different price" do
      copy2 = build(:used_copy, edition_id: 1, price: 20)
      UsedCopy.filter_unique([copy, copy1, copy2]).should == [copy, copy2]
    end

    it "should not filter copies with a different condition rating" do
      copy2 = build(:used_copy, edition_id: 1, condition_rating: 1)
      UsedCopy.filter_unique([copy, copy1, copy2]).should == [copy, copy2]
    end
  end
end