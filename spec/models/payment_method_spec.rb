require 'spec_helper'

describe PaymentMethod do
  let(:payment_method) { build(:payment_method) }
  let(:max_length) { 120 }

  subject{ payment_method }
  
  def create_object(params = {})
    create(:payment_method, params)
  end

  it_should_behave_like "an object with a unique name"
  it_should_behave_like "an object findable by name"

  describe "when destroyed" do
    it "gets deleted with no customers or transactions" do
      payment_method.save
      expect{ payment_method.destroy }.to change{PaymentMethod.count}.by(-1)
    end

    it "raises an exception when customers are present" do
      pm = create(:payment_method, id: 1)
      create(:customer, payment_method_id: 1)
      expect{ pm.destroy }.to raise_exception(ActiveRecord::DeleteRestrictionError)
    end

    it "raises an exception when transactions are present" do
      pm = create(:payment_method, id: 1)
      create(:transaction, payment_method_id: 1)
      expect{ pm.destroy }.to raise_exception(ActiveRecord::DeleteRestrictionError)
    end
  end
end