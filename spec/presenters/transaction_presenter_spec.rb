require 'spec_helper'

describe TransactionPresenter, type: :decorator do
  let(:transaction) { create(:transaction_with_assoc) }
  subject {TransactionPresenter.new(transaction, view)}

  it "gives a valid hash form" do
    subject.as_hash.should be_present
    subject.as_hash.should be_a Hash
  end
end