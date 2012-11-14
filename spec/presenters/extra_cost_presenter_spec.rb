require 'spec_helper'

describe ExtraCostPresenter, type: :decorator do
  let(:extra_cost) { create(:extra_cost_with_order) }
  subject {ExtraCostPresenter.new(extra_cost, view)}

  it "gives a valid hash form", focus: true do
    subject.as_hash.should be_present
    subject.as_hash.should be_a Hash
  end
end