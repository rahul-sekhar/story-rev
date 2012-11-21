require 'spec_helper'

describe Account do
  let(:account) { build(:account) }
  let(:max_length) { 120 }

  subject{ account }
  
  def create_object(params = {})
    create(:account, params)
  end

  it "is valid" do
    account.should be_valid
  end

  it_should_behave_like "an object with a unique name"
  it_should_behave_like "an object findable by name"

  describe "#share" do
    it "cannot be nil" do
      account.share = nil
      account.should be_invalid
    end

    it "can be 0" do
      account.share = 0
      account.should be_valid
    end

    it "can be 100" do
      account.share = 100
      account.should be_valid
    end

    it "can be between 0 and 100" do
      account.share = 64
      account.should be_valid
    end

    it "cannot be less than 0" do
      account.share = -1
      account.should be_invalid
    end

    it "cannot be more than 100" do
      account.share = 101
      account.should be_invalid
    end
  end

  describe "the sum of the shares of all accounts" do
    before do
      create(:account, share: 20)
      create(:account)
      create(:account, share: 25)
    end

    it "can be less than 100" do
      account.share = 20
      account.should be_valid
    end

    it "can be exactly 100" do
      account.share = 55
      account.should be_valid
    end

    it "cannot exceed 100" do
      account.share = 56
      account.should be_invalid
    end

    describe "when the account is being edited" do
      before do
        account.share = 50
        account.save
      end

      it "can be less than 100" do
        account.share = 20
        account.should be_valid
      end

      it "can be exactly 100" do
        account.share = 55
        account.should be_valid
      end

      it "cannot exceed 100" do
        account.share = 56
        account.should be_invalid
      end
    end
  end

  describe "when destroyed" do
    it "destroys any profit shares" do
      create_list(:account_profit_share, 2, account: account)
      expect{ account.destroy }.to change{ AccountProfitShare.count }.by(-2)
    end
  end

  describe "#amount_due" do
    before do
      create(:account_profit_share, amount: 30, account: account)
      create(:account_profit_share, amount: 35, account: account)
      create(:account_profit_share, amount: 30, account: create(:account))
    end

    it "returns the sum of the profit shares" do
      account.amount_due.should == 65
    end
  end
end