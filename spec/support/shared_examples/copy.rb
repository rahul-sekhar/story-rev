shared_examples_for "a copy" do
  describe "price" do
    it "should be required" do
      copy.price = nil
      copy.should be_invalid
      copy.errors[:price].should be_present
    end

    it "should be a non-negative integer" do
      [-1, "a", "1a", "1-", "-", "1_1", 0.56, "1.5"].each do |x|
        copy.price = x
        copy.should be_invalid, x
        copy.errors[:price].should be_present
      end

      [0, 1, 1001, "1"].each do |x|
        copy.price = x
        copy.should be_valid, x
      end
    end
  end

  describe "stock" do
    it "should be required" do
      copy.stock = nil
      copy.should be_invalid
      copy.errors[:stock].should be_present
    end

    it "should be an integer" do
      ["a", "1a", "1-", "-", "1_1", 0.56, "1.5"].each do |x|
        copy.stock = x
        copy.should be_invalid, x
        copy.errors[:stock].should be_present
      end

      [0, 1, 1001, "1", "-1", -65].each do |x|
        copy.stock = x
        copy.should be_valid, x
      end
    end

    it "should be in stock if its stock is above 0" do
      copy.stock = 10
      copy.should be_in_stock, 10
      copy.stock = 1
      copy.should be_in_stock, 1
      copy.stock = 0
      copy.should_not be_in_stock, 0
      copy.stock = -1
      copy.should_not be_in_stock, -1
    end
  end

  describe "copy number and accession id" do
    before do
      unstubbed_copy.book.accession_id = 50
      unstubbed_copy.book.save
    end

    def check_copy_number_and_accession_id(num)
      unstubbed_copy.save
      unstubbed_copy.copy_number.should == num
      unstubbed_copy.accession_id.should == "50-#{num}"
    end

    def new_edition
      new_ed = build(:edition)
      unstubbed_copy.book.editions << new_ed
      unstubbed_copy.book.save
      return new_ed.reload
    end

    it "should be set to 1 for the first copy" do
      unstubbed_copy.save
      check_copy_number_and_accession_id(1)
    end

    it "should be set correctly with a used copy in the same edition" do
      unstubbed_copy.edition.used_copies << build(:used_copy, copy_number: 10)
      check_copy_number_and_accession_id(11)
    end

    it "should be set correctly with a new copy in the same edition" do
      unstubbed_copy.edition.new_copies << build(:new_copy, copy_number: 10)
      check_copy_number_and_accession_id(11)
    end

    it "should be set correctly with a used copy in a different edition" do
      new_edition.used_copies << build(:used_copy, copy_number: 10)
      check_copy_number_and_accession_id(11)
    end

    it "should be set correctly with a new copy in a different edition" do
      new_edition.new_copies << build(:new_copy, copy_number: 10)
      check_copy_number_and_accession_id(11)
    end

    it "should be set correctly, ignoring copies for different books" do
      create(:used_copy_with_book, copy_number: 10)
      create(:new_copy_with_book, copy_number: 10)
      check_copy_number_and_accession_id(1)
    end
  end
end