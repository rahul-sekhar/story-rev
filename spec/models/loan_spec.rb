require 'spec_helper'

describe Loan do
  let(:loan){ build(:loan) }

  it "is valid" do
    loan.should be_valid
  end

  describe "#name" do
    it "cannot be nil" do
      loan.name = nil
      loan.should be_invalid
    end

    it "cannot be blank" do
      loan.name = ""
      loan.should be_invalid
    end

    it "cannot have just spaces" do
      loan.name = "  "
      loan.should be_invalid
    end

    it "can be a duplicate" do
      create(:loan, name: "Test")
      loan.name = "Test"
      loan.should be_valid
      loan.save.should == true
    end

    it "strips extra spaces" do
      loan.name = "  Test  "
      loan.save
      loan.name.should == "Test"
    end

    it "cannot be more than 200 characters" do
      loan.name = "a" * 200
      loan.should be_valid
      loan.name = "a" * 201
      loan.should be_invalid
    end
  end

  describe "#amount" do
    it "cannot be nil" do
      loan.amount = nil
      loan.should be_invalid
    end

    it "cannot be negative" do
      loan.amount = -1
      loan.should be_invalid
    end

    it "cannot be a non-integer" do
      loan.amount = "a"
      loan.should be_invalid
    end

    it "can be 0" do
      loan.amount = 0
      loan.should be_valid
    end

    it "can be positive" do
      loan.amount = 50
      loan.should be_valid
    end
  end

  describe "#payment" do
    before do
      loan.update_attributes(amount: 1000)
    end
    
    it "is invalid if greater than the amount" do
      loan.payment = 1001
      loan.should be_invalid
    end

    it "is valid if equal to the payment" do
      loan.payment = 1000
      loan.should be_valid
    end

    it "is valid if between 0 and the payment" do
      loan.payment = 500
      loan.should be_valid
    end

    it "is valid if 0" do
      loan.payment = 0
      loan.should be_valid
    end

    it "is invalid if negative" do
      loan.payment = -1
      loan.should be_invalid
    end

    it "is deducted from the amount" do
      loan.payment = 200
      loan.amount.should == 800
    end
  end
end