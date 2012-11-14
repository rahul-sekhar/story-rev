require 'spec_helper'

describe Transaction do
  let(:transaction){ build(:transaction) }

  it "is valid" do
    transaction.should be_valid
  end

  it "requries a transaction category" do
    transaction.transaction_category = nil
    transaction.should be_invalid
  end

  describe "when destroyed" do
    it "gets deleted with no orders" do
      transaction.save
      expect{ transaction.destroy }.to change{Transaction.count}.by(-1)
    end

    it "nullifies the transaction_id for an order when present"  do
      o = create(:complete_order_with_customer)
      o.update_attributes(paid: true)
      tr = o.transaction
      tr.destroy
      o.reload.transaction_id.should == nil
    end
  end

  describe "#date" do
    it "allows the date to be set" do
      @date = 1.day.ago
      transaction.date = @date
      transaction.save
      transaction.reload.date.should == @date
    end

    it "sets the date to the current date if the date is not set" do
      @date = DateTime.now
      DateTime.stub(:now).and_return(@date)
      transaction.save
      transaction.date.should == @date
    end
  end

  describe "#first_date" do
    it "returns 1900 if no transactions are present" do
      Transaction.first_date.should == Date.new(1900)
    end

    it "returns the first transactions date if transactions are present" do
      @date = Date.today
      create(:transaction, date: @date - 5.days)
      create(:transaction, date: @date - 6.days)
      create(:transaction, date: @date - 2.days)
      Transaction.first_date.should == @date - 6.days
    end
  end
  
  describe "#short_date" do
    it "returns the date formatted as a short date" do
      @date = Date.new(1950)
      transaction.date = @date
      transaction.short_date.should == "01-01-1950"
    end

    it "sets the date given a short date" do
      transaction.short_date = "05-02-1980"
      transaction.date.should == Date.new(1980) + 1.month + 4.days
    end
  end

  describe "other party" do
    it "allows a maximum of 200 characters" do
      transaction.other_party = "a" * 200
      transaction.should be_valid
      transaction.other_party = "a" * 201
      transaction.should be_invalid
    end
  end

  describe "credit" do
    it "cannot be nil" do
      transaction.credit = nil
      transaction.should be_invalid
    end

    it "can be 0" do
      transaction.credit = 0
      transaction.should be_valid
    end

    it "can be positive" do
      transaction.credit = 10
      transaction.should be_valid
    end

    it "cannot be negative" do
      transaction.credit = -5
      transaction.should be_invalid
    end
  end

  describe "debit" do
    it "cannot be nil" do
      transaction.debit = nil
      transaction.should be_invalid
    end

    it "can be 0" do
      transaction.debit = 0
      transaction.should be_valid
    end

    it "can be positive" do
      transaction.debit = 10
      transaction.should be_valid
    end

    it "cannot be negative" do
      transaction.debit = -5
      transaction.should be_invalid
    end
  end
end