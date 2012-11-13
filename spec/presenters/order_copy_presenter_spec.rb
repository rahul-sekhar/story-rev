require 'spec_helper'

describe OrderCopyPresenter, type: :decorator do
  let(:order_copy) { build(:order_copy) }
  subject {OrderCopyPresenter.new(order_copy, view)}

  it "gives a valid hash form with a used copy" do
    subject.as_hash.should be_present
    subject.as_hash.should be_a Hash
  end

  it "gives a valid hash form with a new copy" do
    order_copy.copy.destroy
    order_copy.new_copy = create(:new_copy_with_book)
    subject.as_hash.should be_present
    subject.as_hash.should be_a Hash
  end
end