require 'spec_helper'

describe Copy do
  it "should not be saveable as a standalone class" do
    copy = Copy.new(price: 50)
    copy.save.should == false
    copy.should be_new_record
  end

  describe "#find_used_or_new" do
    it "returns the copy as a new copy if it is new" do
      c = create(:new_copy_with_book)
      Copy.find_used_or_new(c.id).should be_a NewCopy
    end

    it "returns the copy as a used copy if it is used" do
      c = create(:used_copy_with_book)
      Copy.find_used_or_new(c.id).should be_a UsedCopy
    end

    it "raises an exception for a non existant ID" do
      expect{ Copy.find_used_or_new(5) }.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end
end