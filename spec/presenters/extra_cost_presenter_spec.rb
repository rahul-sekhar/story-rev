require 'spec_helper'

describe ExtraCostPresenter, type: :decorator do
  let(:order){ create(:complete_order_with_customer) }
  let(:extra_cost){ build(:extra_cost, complete_order: order) }
  subject {ExtraCostPresenter.new(extra_cost, view)}

  it "gives a valid hash form" do
    subject.as_hash.should be_present
    subject.as_hash.should be_a Hash
  end
end