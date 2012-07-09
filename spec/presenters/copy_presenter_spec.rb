require 'spec_helper'

describe CopyPresenter, :type => :decorator do
  let(:copy) { Copy.new }
  subject { CopyPresenter.new(copy, view) }

  describe "accession_id_sortable" do
    it "should return the accession id as a decimal number" do
      copy.should_receive(:accession_id).and_return("501-23")
      copy.should_receive(:copy_number).and_return(23)

      subject.accession_id_sortable.should == 501.23
    end
  end

  describe "condition_description" do
    it "should return the condition description if one is present" do
      copy.stub(:condition_description).and_return("Blah")
      subject.condition_description.should == "Blah"
    end

    it "should return appropriate values depending on the condition rating when the description is not set" do
      copy.stub(:condition_description)
      {
        1 => "Acceptable", 
        2 => "Acceptable",
        3 => "Good",
        4 => "Excellent",
        5 => "Like new"
      }.each do |key, val|
        copy.stub(:condition_rating).and_return(key)
        subject.condition_description.should == val
      end
    end
  end
end