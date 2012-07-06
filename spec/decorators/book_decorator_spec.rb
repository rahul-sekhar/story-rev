require 'spec_helper'

describe BookDecorator, :type => :decorator do
  let(:book) { Book.new }
  subject {BookDecorator.new(book)}

  it "should include currency methods" do
    subject.should respond_to(:to_currency)
  end

  describe "age_level" do
    it "should be blank with no age limits set" do
      subject.age_level.should be_blank
    end

    it "should be a range with both age limits set" do
      subject.age_from, subject.age_to = 10, 50
      subject.age_level.should == "10 - 50"
    end

    it "should be only the lower limit when the upper limit is not set" do
      subject.age_from = 15
      subject.age_level.should == "15+"
    end

    it "should be just the age when both limits are the same" do
      subject.age_from, subject.age_to = 12, 12
      subject.age_level.should == "12"
    end
  end

  describe "creators" do
    before { subject.author_name = "Test Author" }

    it "should be the author name when no illustrator is present" do
      subject.creators.should == "Test Author"
    end

    it "should be both the author and illustrator names when both are present" do
      subject.illustrator_name = "Test Illustrator"
      subject.creators.should == "Test Author and Test Illustrator"
    end

    it "should be only a single name when the author and illustrator names are identical" do
      subject.illustrator_name = "Test Author"
      subject.creators.should == "Test Author"
    end
  end

  describe "used_copy_min_price" do
    it "should return the book's used_copy_min_price with the currency added" do
      book.should_receive(:used_copy_min_price).and_return(40)
      subject.should_receive(:to_currency).and_return(:returned_currency)
      subject.used_copy_min_price.should equal(:returned_currency)
    end

    it "should return nil if the book's used_copy_min_price is nil" do
      book.should_receive(:used_copy_min_price).and_return(nil)
      subject.used_copy_min_price.should be_nil
    end
  end

  describe "new_copy_min_price" do
    it "should return the book's new_copy_min_price with the currency added" do
      book.should_receive(:new_copy_min_price).and_return(40)
      subject.should_receive(:to_currency).and_return(:returned_currency)
      subject.new_copy_min_price.should equal(:returned_currency)
    end

    it "should return nil if the book's new_copy_min_price is nil" do
      book.should_receive(:new_copy_min_price).and_return(nil)
      subject.new_copy_min_price.should be_nil
    end
  end

  describe "award_list" do
    it "should return a list of book award names" do
      book_award1 = double("book_award")
      book_award1.stub(:full_name).and_return("Award 1")

      book_award2 = double("book_award")
      book_award2.stub(:full_name).and_return("Award 2")

      subject.stub(:book_awards).and_return([book_award1, book_award2])

      subject.award_list.should == "Award 1, Award 2"
    end
  end
end