require 'spec_helper'

describe TransactionCategory do
  let(:transaction_category) { build(:transaction_category) }
  let(:max_length) { 120 }

  subject{ transaction_category }
  
  def create_object(params = {})
    create(:transaction_category, params)
  end

  it_should_behave_like "an object with a unique name"
  it_should_behave_like "an object findable by name"

  describe "when destroyed" do
    it "gets deleted with no customers or transactions" do
      transaction_category.save
      expect{ transaction_category.destroy }.to change{TransactionCategory.count}.by(-1)
    end

    it "raises an exception when transactions are present" do
      tc = create(:transaction_category)
      create(:transaction, transaction_category: tc)
      expect{ tc.destroy }.to raise_exception(ActiveRecord::DeleteRestrictionError)
    end
  end

  describe "#find_or_create" do
    describe "when a matching object doesn't exist" do
      it "creates a new object" do
        expect {TransactionCategory.find_or_create("test")}.to change{TransactionCategory.count}.by(1)
      end

      it "returns an object with the passed name" do
        TransactionCategory.find_or_create("test").name.should == "test"
      end
    end

    describe "when a matching object exists" do
      before do
        @t = create(:transaction_category, name: "Test")
      end
      it "does not create a new object" do
        expect {TransactionCategory.find_or_create("test")}.to change{TransactionCategory.count}.by(0)
      end

      it "returns the existing object" do
        TransactionCategory.find_or_create("test").should == @t
      end
    end
  end
end