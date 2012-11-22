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

  describe "#name, when edited" do
    it "edits any existing transactions" do
      trans1 = create(:transaction, other_party: account.name, account: account)
      trans2 = create(:transaction, other_party: "Blah blah", account: account)
      account.name = "Tchah"
      account.save
      trans1.reload.other_party.should == "Tchah"
      trans2.reload.other_party.should == "Tchah"
    end
  end

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

    it "destroys any transactions" do
      create_list(:transaction, 2, account: account)
      expect{ account.destroy }.to change{ Transaction.count }.by(-2)
    end
  end

  describe "#amount_due" do
    before do
      create(:account_profit_share, amount: 40, account: account)
      create(:account_profit_share, amount: 35, account: account)
      create(:account_profit_share, amount: 30, account: create(:account))
      create(:transaction, debit: 60, account: account)
      create(:transaction, debit: 20, account: create(:account))
      create(:transaction, debit: 5, account: account)
    end

    it "returns the sum of the profit shares minus the sum of the payment transactions" do
      account.amount_due.should == 10
    end
  end

  describe "#payment" do
    it "doesn't create a transaction when not set" do
      expect { account.save }.to change{ Transaction.count }.by(0)
    end

    it "doesn't create a transaction when blank" do
      account.payment = ""
      expect { account.save }.to change{ Transaction.count }.by(0)
    end

    it "doesn't create a transaction when set to 0" do
      account.payment = 0
      expect { account.save }.to change{ Transaction.count }.by(0)
    end

    it "doesn't create a transaction when set below 0" do
      account.payment = -5
      expect { account.save }.to change{ Transaction.count }.by(0)
    end

    describe "when set to a positive integer" do
      before{ account.payment = 12 }
      let(:transaction){ account.transactions.last }

      it "creates a transaction" do
        expect { account.save }.to change{ Transaction.count }.by(1)
      end

      specify "the transaction has a debit of the payment amount" do
        account.save
        transaction.debit.should == 12
      end

      specify "the transaction has the account name" do
        account.save
        transaction.other_party.should == account.name
      end

      it "creates a 'Profit payment' transaction category when one does not exist" do
        expect{ account.save }.to change{ TransactionCategory.count }.by(1)
        transaction.transaction_category_name.should == "Profit payment"
      end

      it "uses a 'Profit payment' category if one exists" do
        categ = create(:transaction_category, name: 'Profit payment')
        expect{ account.save }.to change{ TransactionCategory.count }.by(0)
        transaction.transaction_category.should == categ
      end
    end
  end
end