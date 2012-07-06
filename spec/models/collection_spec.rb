require 'spec_helper'

describe Collection do
  let(:collection) { build(:collection) }
  let(:max_length) { 200 }

  subject{ collection }
  
  def create_object(params = {})
    create(:collection, params)
  end

  it_should_behave_like "an object with a unique name"

  describe "#from_list" do
    it "should split a comma separated list of words and return a collection for each" do
      Collection.stub(:name_is)
      list = Collection.from_list("Some books, Other books")
      list.length.should == 2
      list.map{ |x| x.name }.should include("Some books", "Other books")
      list.each{ |x| x.should be_a Collection }
    end

    it "should return existing collections" do
      collection_double = double("collection")
      Collection.should_receive(:name_is) do |name|
        collection_double if name == "Existing collection"
      end.twice

      list = Collection.from_list("Some books, Existing collection")
      list.length.should == 2
      list.should include(collection_double)
    end

    it "should remove blank values" do
      Collection.stub(:name_is)
      list = Collection.from_list("Some books, , Other books,")
      list.length.should == 2
    end

    it "should remove duplicates" do
      Collection.stub(:name_is)
      list = Collection.from_list("Some books, Other books, some books, Other books, SOME BOOKS  ")
      list.length.should == 2
    end
  end
end