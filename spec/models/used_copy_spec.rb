require 'spec_helper'

describe UsedCopy do
  let(:copy) { build(:used_copy_with_book) }

  it_should_behave_like "a copy"

  it "should only retrieve used copies from the database" do
    copy.save
    copy1 = create(:used_copy_with_book)
    new_copy = create(:new_copy_with_book)
    used_copies = UsedCopy.all
    used_copies.should include(copy, copy1)
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

  it "should allow setting the stock as a boolean" do
    copy.set_stock = false
    copy.stock.should == 0
    copy.set_stock = true
    copy.stock.should == 1
  end

  it "should set the book date when a fresh copy is created" do
    old_date = copy.book.book_date
    copy.save
    copy.book.book_date.should > old_date
  end

  it "should not set the book date when a fresh copy is created and set to out of stock" do
    old_date = copy.book.book_date
    copy.set_stock = false
    copy.save
    copy.book.book_date.should == old_date
  end
  
  it "should not set the book date when a fresh copy is created and goes back in stock" do
    copy.save
    old_date = copy.book.book_date
    copy.set_stock = false
    copy.save
    copy.book.book_date.should == old_date
    copy.set_stock = true
    copy.save
    copy.book.book_date.should == old_date
  end

  it "should return the condition description when one is present" do
    copy.condition_description = "Somewhat decent condition"
    copy.condition_description.should == "Somewhat decent condition"
  end

  it "should return a description based on the rating when no description is present" do
    { 1 => "Acceptable", 2 => "Acceptable", 3 => "Good", 4 => "Excellent", 5 => "Like new" }.each do |rating, description|
      copy.condition_rating = rating
      copy.condition_description.should == description
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
    let (:copy1) { build(:used_copy, edition_id: copy.edition_id) }

    it "should filter out copies with the same attributes" do
      copy2 = build(:used_copy, edition_id: copy.edition_id)
      UsedCopy.filter_unique([copy, copy1, copy2]).should == [copy]
    end

    it "should not filter copies from a different edition" do
      new_edition = create(:edition, book_id: copy.book.id)
      copy2 = build(:used_copy, edition_id: new_edition.id)
      UsedCopy.filter_unique([copy, copy1, copy2]).should == [copy, copy2]
    end

    it "should not filter copies with a different price" do
      copy2 = build(:used_copy, edition_id: copy.edition_id, price: 20)
      UsedCopy.filter_unique([copy, copy1, copy2]).should == [copy, copy2]
    end

    it "should not filter copies with a different condition rating" do
      copy2 = build(:used_copy, edition_id: copy.edition_id, condition_rating: 1)
      UsedCopy.filter_unique([copy, copy1, copy2]).should == [copy, copy2]
    end
  end
end