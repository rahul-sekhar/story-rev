require 'spec_helper'

describe ExtraCost do
  let(:order){ create(:complete_order_with_customer) }
  let(:extra_cost){ build(:extra_cost, complete_order: order) }

  it "is valid" do
    extra_cost.should be_valid
  end

  describe "#name" do
    it "is invalid without a name" do
      extra_cost.name = nil
      extra_cost.should be_invalid
    end

    it "is invalid with a name longer than 255 characters" do
      extra_cost.name = "a" * 255
      extra_cost.should be_valid
      extra_cost.name = "a" * 256
      extra_cost.should be_invalid
    end

    it "is invalid with a blank name" do
      extra_cost.name = ""
      extra_cost.should be_invalid      
    end
  end

  describe "#amount" do
    it "is invalid without an amount" do
      extra_cost.amount = nil
      extra_cost.should be_invalid
    end

    it "is valid with an amount of 0" do
      extra_cost.amount = 0
      extra_cost.should be_valid
    end

    it "is valid with a positive amount" do
      extra_cost.amount = 52
      extra_cost.should be_valid
    end

    it "is invalid with a negative amount" do
      extra_cost.amount = -5
      extra_cost.should be_invalid
    end
  end

  describe "#expenditure" do
    it "defaults to 0" do
      ExtraCost.new.expenditure.should == 0
    end

    it "is invalid without an expenditure" do
      extra_cost.expenditure = nil
      extra_cost.should be_invalid
    end

    it "is valid with an expenditure of 0" do
      extra_cost.expenditure = 0
      extra_cost.should be_valid
    end

    it "is valid with a positive expenditure" do
      extra_cost.expenditure = 52
      extra_cost.should be_valid
    end

    it "is invalid with a negative expenditure" do
      extra_cost.expenditure = -5
      extra_cost.should be_invalid
    end
  end

  it "is invalid without an order" do
    extra_cost.complete_order = nil
    extra_cost.should be_invalid
  end

  it "updates its orders total when created" do
    ec = create(:extra_cost, complete_order: order, amount: 50, expenditure: 10)
    ec.order.total_amount.should == 50
  end

  it "updates its orders total when saved" do
    ec = create(:extra_cost, complete_order: order, amount: 50, expenditure: 10)
    ec.order.total_amount.should == 50
    ec.update_attributes(amount: 40)
    ec.order.total_amount.should == 40
  end

  it "updates its orders total when destroyed" do
    ec = create(:extra_cost, complete_order: order, amount: 50, expenditure: 10)
    ec.order.total_amount.should == 50
    ec.destroy
    ec.order.total_amount.should == 0
  end

  context "with an order transaction" do
    before do
      order.paid = true
      order.save
      @t = order.transaction
    end

    it "updates the transaction when created" do
      ec = create(:extra_cost, complete_order: order, amount: 50, expenditure: 10)
      @t.reload.credit.should == 50
      @t.debit.should == 10
    end

    it "updates the transaction when saved" do
      ec = create(:extra_cost, complete_order: order, amount: 50, expenditure: 10)
      @t.reload.credit.should == 50
      @t.debit.should == 10
      ec.update_attributes(amount: 40, expenditure: 20)
      @t.reload.credit.should == 40
      @t.debit.should == 20
    end

    it "updates the transaction when destroyed" do
      ec = create(:extra_cost, complete_order: order, amount: 50, expenditure: 10)
      @t.reload.credit.should == 50
      @t.debit.should == 10
      ec.destroy
      @t.reload.credit.should == 0
      @t.debit.should == 0
    end
  end
end