require 'spec_helper'

describe Edition do
  let (:edition) { build :edition }

  it "should require a format" do
    edition.format = nil
    edition.should be_invalid
  end

  it "should require a language" do
    edition.language = nil
    edition.should be_invalid
  end

  it "should set the language to English by default" do
    edition.language.name.should == "English"
  end

  it "should check the length of the ISBN" do
    edition.isbn = "1" * 255
    edition.should be_valid
    edition.isbn = "1" * 256
    edition.should be_invalid
  end

  [:publisher, :format, :language].each do |field|
    it "should check for an invalid #{field}" do
      edition.send("#{field}=", build(field))
      edition.send(field).stub(:valid?).and_return(false)
      edition.should be_invalid
      edition.errors[field].should be_present
    end
  end

  it "should convert an ISBN into its raw numerical form" do
    edition.isbn = "1-152151-124-123-12"
    edition.save
    edition.raw_isbn.should == "115215112412312"
    edition.isbn = "00151221561216"
    edition.save
    edition.raw_isbn.should == "00151221561216"
  end

  it "should check the ISBN format" do
    ["123A-1", "12 1", "A-A", "1_1", "-", "-1213", "12312-", "123--12"].each do |x|
      edition.isbn = x
      edition.should be_invalid, x
      edition.errors[:isbn].should be_present
    end
    ["124", "12-12", "12-412-512-1", "0012", "0"].each do |x|
      edition.isbn = x
      edition.should be_valid, x
    end
  end

  it "should allow a blank ISBN" do
    edition.isbn = ""
    edition.should be_valid
  end
end