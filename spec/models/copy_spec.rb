require 'spec_helper'

describe Copy do
  it "should not be saveable as a standalone class" do
    copy = Copy.new(price: 50)
    copy.save.should == false
    copy.should be_new_record
  end
end