shared_examples_for "a copy" do
  it "should require an edition" do
    copy.edition = nil
    copy.should be_invalid
    copy.errors[:edition].should be_present
  end

  describe "price" do
    it "should be required" do
      copy.price = nil
      copy.should be_invalid
      copy.errors[:price].should be_present
    end

    it "should be a non-negative integer" do
      [-1, "a", "1a", "1-", "-", "1_1", 0.56, "1.5"].each do |x|
        copy.price = x
        copy.should be_invalid
        copy.errors[:price].should be_present
      end

      [0, 1, 1001, "1"].each do |x|
        copy.price = x
        copy.should be_valid
      end
    end
  end

  describe "cost_price" do
    it "should be required" do
      copy.cost_price = nil
      copy.should be_invalid
      copy.errors[:cost_price].should be_present
    end

    it "should be a non-negative integer" do
      [-1, "a", "1a", "1-", "-", "1_1", 0.56, "1.5"].each do |x|
        copy.cost_price = x
        copy.should be_invalid
        copy.errors[:cost_price].should be_present
      end

      [0, 1, 30, "1"].each do |x|
        copy.cost_price = x
        copy.should be_valid
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
        copy.should be_invalid
        copy.errors[:stock].should be_present
      end

      [0, 1, 1001, "1", "-1", -65].each do |x|
        copy.stock = x
        copy.should be_valid
      end
    end

    it "should be in stock if its stock is above 0" do
      [10, 1].each do |x|
        copy.stock = x
        copy.should be_in_stock
      end
      [0, -1].each do |x|
        copy.stock = x
        copy.should_not be_in_stock
      end
    end
  end

  describe "condition rating" do
    it "should be required" do
      copy.condition_rating = nil
      copy.should be_invalid
      copy.errors[:condition_rating].should be_present
    end

    it "should be an integer between 0 and 5" do
      ["-1", "0.5", 0.56, 6, -2].each do |x|
        copy.condition_rating = x
        copy.should be_invalid
        copy.errors[:condition_rating].should be_present
      end

      [0, 1, 5, "3"].each do |x|
        copy.condition_rating = x
        copy.should be_valid
      end
    end
  end

  describe "new_copy" do
    it "should be required" do
      copy.new_copy = nil
      copy.should be_invalid
      copy.errors[:new_copy].should be_present
    end
  end

  describe "copy number and accession id" do
    before do
      copy.book.accession_id = 50
      copy.book.save
    end

    def check_copy_number_and_accession_id(num)
      copy.save
      copy.copy_number.should == num
      copy.accession_id.should == "50-#{num}"
    end

    def new_edition
      new_ed = build(:edition)
      copy.book.editions << new_ed
      copy.book.save
      return new_ed.reload
    end

    it "should be set to 1 for the first copy" do
      copy.save
      check_copy_number_and_accession_id(1)
    end

    it "should be set correctly with a used copy in the same edition" do
      copy.edition.used_copies << build(:used_copy, copy_number: 10)
      check_copy_number_and_accession_id(11)
    end

    it "should be set correctly with a new copy in the same edition" do
      copy.edition.new_copies << build(:new_copy, copy_number: 10)
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