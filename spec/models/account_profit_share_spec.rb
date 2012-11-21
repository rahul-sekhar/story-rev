require 'spec_helper'

describe AccountProfitShare do
  let(:share){ build(:account_profit_share) }

  it "is valid" do
    share.should be_valid
  end

  it "requires an order" do
    share.complete_order = nil
    share.should be_invalid
  end

  it "requires an account" do
    share.account = nil
    share.should be_invalid
  end

  describe "#amount" do
    it "cannot be nil" do
      share.amount = nil
      share.should be_invalid
    end

    it "can be 0" do
      share.amount = 0
      share.should be_valid
    end

    it "can be a positive integer" do
      share.amount = 1001
      share.should be_valid
    end

    it "cannot be less than 0" do
      share.amount = -1
      share.should be_invalid
    end
  end
end