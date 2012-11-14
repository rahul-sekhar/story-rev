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
      copy.should be_invalid
      copy.errors[:required_stock].should be_present
    end

    [0, 1, 1001, "1"].each do |x|
      copy.required_stock = x
      copy.should be_valid
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

  describe "#profit_percentage", :focus do
    it "returns the profit percentage" do
      copy.cost_price = 20
      copy.price = 120
      copy.profit_percentage.should == 83
    end

    it "returns 0 if the price is 0" do
      copy.cost_price = 20
      copy.price = 0
      copy.profit_percentage.should == 0
    end

    it "does not change the cost price when not set" do
      copy.cost_price = 30
      copy.price = 100
      copy.save
      copy.cost_price.should == 30
      copy.reload.save
      copy.cost_price.should == 30
    end

    it "changes the cost price when set" do
      copy.cost_price = 30
      copy.price = 100
      copy.save
      copy.reload.profit_percentage = 65
      copy.save
      copy.cost_price.should == 35
    end

    it "should round off properly" do
      copy.price = 99
      copy.profit_percentage = 25
      copy.save
      copy.cost_price.should == 74
      copy.profit_percentage.should == 25
    end

    it "should round off properly - test two" do
      copy.price = 97
      copy.profit_percentage = 25
      copy.save
      copy.cost_price.should == 73
      copy.profit_percentage.should == 25
    end

    it "changes the cost price when set to a string" do
      copy.cost_price = 30
      copy.price = 100
      copy.save
      copy.reload.profit_percentage = "40"
      copy.save
      copy.cost_price.should == 60
    end

    it "does not change the cost price when read, but not set" do
      copy.cost_price = 30
      copy.price = 100
      copy.save
      copy.reload
      copy.cost_price = 20
      copy.profit_percentage
      copy.save
      copy.cost_price.should == 20
    end

    it "changes the cost price to 0 when set to 0" do
      copy.cost_price = 30
      copy.price = 100
      copy.save
      copy.profit_percentage = 0
      copy.save
      copy.cost_price.should == 100
    end

    it "changes the cost price to the price when set to 100" do
      copy.cost_price = 30
      copy.price = 100
      copy.save
      copy.profit_percentage = 100
      copy.save
      copy.cost_price.should == 0
    end

    it "is valid when an integer from 0 to 100" do
      [0, 1, 80, 100, "5"].each do |x|
        copy.profit_percentage = x
        copy.should be_valid
      end
    end

    it "is invalid when not an integer from 0 to 100" do
      [-1, 101, "a"].each do |x|
        copy.profit_percentage = x
        copy.should be_valid
      end
    end
  end
end