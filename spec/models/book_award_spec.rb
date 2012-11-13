require "spec_helper"

describe BookAward do
  let(:book_award) { build(:book_award) }
  subject { book_award }

  describe "year" do
    it "should be an integer" do
      ["1a", "0", 5.5].each do |x|
        book_award.year = x
        book_award.should be_invalid
      end
    end

    it "should have a lower limit of 1001" do
      book_award.year = 1001
      book_award.should be_valid
      book_award.year = 1000
      book_award.should be_invalid
    end

    it "should have an upper limit of 2099" do
      book_award.year = 2099
      book_award.should be_valid
      book_award.year = 2100
      book_award.should be_invalid
    end
  end

  describe "full name" do
    before { book_award.award.stub(:full_name).and_return("Award Name") }
    subject { book_award.full_name }
    
    it "should include the year when it is present" do
      book_award.year = 2010
      subject.should == "Award Name 2010"
    end

    it "should omit the the year when it is nil" do
      book_award.year = nil
      subject.should == "Award Name"
    end
  end
end