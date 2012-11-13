require 'spec_helper'

describe Edition do
  let (:edition) { build :edition_with_book }

  it "should require a format" do
    edition.format = nil
    edition.should be_invalid
    edition.errors.should have_key :format
  end

  it "should require a book" do
    edition.book = nil
    edition.should be_invalid
    edition.errors.should have_key :book
  end

  it "should set the language to English by default" do
    edition.language_name.should == "English"
  end

  it "should check the length of the ISBN" do
    edition.isbn = "1" * 50
    edition.should be_valid
    edition.isbn = "1" * 51
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
  end

  it "should check the ISBN format" do
    ["123A-1", "12 1", "A-A", "1_1", "-", "-1213", "12312-", "123--12"].each do |x|
      edition.isbn = x
      edition.should be_invalid
      edition.errors[:isbn].should be_present
    end
    ["124", "12-12", "12-412-512-1", "0"].each do |x|
      edition.isbn = x
      edition.should be_valid
    end
  end

  it "should allow a blank ISBN" do
    edition.isbn = ""
    edition.should be_valid
  end

  describe "after being destroyed" do
    it "should destroy child used copies" do
      edition.save
      create(:used_copy, edition: edition)
      expect{ edition.destroy }.to change{ UsedCopy.count }.by(-1)
    end

    it "should destroy child new copies" do
      edition.save
      create(:new_copy, edition: edition)
      expect{ edition.destroy }.to change{ NewCopy.count }.by(-1)
    end
  end

  describe "#default_cost_price" do
    before do
      c = ConfigData.access
      c.default_cost_price = 40
      c.save
    end
    it "returns the default when the book has no book type" do
      create(:default_cost_price, format: edition.format)
      edition.default_cost_price.should == 40
    end

    it "returns the default if no values exist" do
      edition.book.book_type = create(:book_type)
      edition.default_cost_price.should == 40
    end

    it "returns the default if the format and book type aren't matched" do
      create(:default_cost_price, cost_price: 60)
      create(:default_cost_price, cost_price: 30)
      edition.default_cost_price.should == 40
    end

    it "returns the matched cost price" do
      f = edition.format
      b = create(:book_type)
      create(:default_cost_price, format: f, cost_price: 20)
      create(:default_cost_price, format: f, book_type: b, cost_price: 70)
      create(:default_cost_price, book_type: b, cost_price: 90)
      edition.book.book_type = b
      edition.default_cost_price.should == 70
    end
  end
end