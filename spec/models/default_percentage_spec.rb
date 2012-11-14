require 'spec_helper'

describe DefaultPercentage do
  let(:dp){ build(:default_percentage) }

  specify "factory is valid" do
    dp.should be_valid
  end

  it "requires a publisher" do
    dp.publisher = nil
    dp.should be_invalid
  end

  describe "#percentage" do
    it "is valid when between 0 and 100" do
      [0,1,50,100].each do |x|
        dp.percentage = x
        dp.should be_valid
      end
    end

    it "is invalid otherwise" do
      [-1,-5, "a", 101].each do |x|
        dp.percentage = x
        dp.should be_invalid
      end
    end
  end

  it "is invalid with a publisher" do
    dp1 = create(:default_percentage)
    dp.publisher = dp1.publisher
    dp.should be_invalid
  end
end