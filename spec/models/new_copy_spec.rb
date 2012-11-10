require 'spec_helper'

describe NewCopy do
  let(:copy) { build(:new_copy_with_book) }

  it_should_behave_like "a copy"

  it "should only retrieve new copies from the database" do
    copy1 = create(:new_copy_with_book)
    copy2 = create(:new_copy_with_book)
    used_copy = create(:used_copy_with_book)
    new_copies = NewCopy.all
    new_copies.should include(copy1, copy2)
    new_copies.should_not include(used_copy)
  end

  it "should initially be out of stock" do
    copy.should_not be_in_stock
    copy.stock.should == 0
  end

  it "should have new copy set to true" do
    copy.new_copy.should == true
  end

  it "should have a default condition rating of 5" do
    copy.condition_rating.should == 5
  end

  it "should ensure that required stock is a positive integer" do
    [-1, "a", "1a", "1-", "-", "1_1", 0.56, "1.5"].each do |x|
      copy.required_stock = x
      copy.should be_invalid, x
      copy.errors[:required_stock].should be_present
    end

    [0, 1, 1001, "1"].each do |x|
      copy.required_stock = x
      copy.should be_valid, x
    end
  end

  describe "book_date" do
    it "should not update the book date if the copy is saved with no stock" do
      copy.book.should_not_receive(:set_book_date)
      copy.save
    end

    it "should update the book date if the copy is saved with some stock" do
      copy.book.should_receive(:set_book_date)
      copy.stock = 5
      copy.save
    end

    it "should update the book date if the book copy out of stock then comes back in stock" do
      copy.save
      copy.book.should_receive(:set_book_date)
      copy.stock = 10
      copy.save
    end

    it "should not update the book date if the copy goes out of stock and then the stock goes negative" do
      copy.save
      copy.book.should_not_receive(:set_book_date)
      copy.stock = -1
      copy.save
    end
    
    it "should not update the book date if the copy does not go out of stock" do
      copy.book.should_receive(:set_book_date).once
      copy.stock = 1
      copy.save
      copy.stock = 10
      copy.save
    end
  end
end