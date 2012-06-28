require 'spec_helper'
require "#{Rails.root}/spec/support/copy"

describe NewCopy do
  let(:copy) { build(:new_copy_with_book) }

  it_should_behave_like "a copy"

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
end