require 'spec_helper'

describe DefaultCostPrice do
  let(:dcp){ build(:default_cost_price) }

  specify "factory is valid" do
    dcp.should be_valid
  end

  it "requires a book_type" do
    dcp.book_type = nil
    dcp.should be_invalid
  end

  it "requires a format" do
    dcp.format = nil
    dcp.should be_invalid
  end

  describe "#cost_price" do
    it "is valid when 0 or above" do
      [0,1,1000, "50"].each do |x|
        dcp.cost_price = x
        dcp.should be_valid, x
      end
    end

    it "is invalid when below 0 or not an integer" do
      [-1,-5, "a"].each do |x|
        dcp.cost_price = x
        dcp.should be_invalid, x
      end
    end
  end

  it "is invalid with a duplicate book type and format" do
    dcp1 = create(:default_cost_price)
    dcp.format = dcp1.format
    dcp.book_type = dcp1.book_type
    dcp.should be_invalid
  end
end