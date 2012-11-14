require 'spec_helper'

describe CopyPresenter, type: :decorator do
  let(:copy) { build(:used_copy_with_book) }
  subject {CopyPresenter.new(copy, view)}

  describe "#accession_id_sortable" do
    it "returns the accession number as a decimal" do
      copy.stub(:accession_id).and_return("123-14")
      copy.stub(:copy_number).and_return(14)
      subject.accession_id_sortable.should == 123.0014
    end
  end

  describe "#condition_description" do
    it "returns the copy condition description if present" do
      copy.stub(:condition_description).and_return(:desc)
      subject.condition_description.should == :desc
    end

    it "returns a description based on the copy rating if the copy description is not present" do
      {
        "1" => "Acceptable", 
        "2" => "Acceptable", 
        "3" => "Good", 
        "4" => "Excellent", 
        "5" => "Like new"
      }.each do |key, val|
        copy.stub(:condition_rating).and_return(key)
        subject.condition_description.should == val
      end
    end
  end

  describe "#price" do
    it "returns the copies price, formatted to a currency" do
      copy.should_receive(:price).and_return(40)
      CurrencyMethods.should_receive(:to_currency).and_return(:returned_currency)
      subject.price.should equal(:returned_currency)
    end
  end

  it "gives a valid hash form" do
    subject.as_hash.should be_present
    subject.as_hash.should be_a Hash
  end
end