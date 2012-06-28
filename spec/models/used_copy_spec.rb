require 'spec_helper'
require "#{Rails.root}/spec/support/copy"

describe UsedCopy do
  let(:copy) { build(:used_copy_with_book) }

  it_should_behave_like "a copy"

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
end