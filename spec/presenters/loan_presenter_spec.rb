require 'spec_helper'

describe LoanPresenter, type: :decorator do
  let(:loan) { create(:loan) }
  subject {LoanPresenter.new(loan, view)}

  it "gives a valid hash form" do
    subject.as_hash.should be_present
    subject.as_hash.should be_a Hash
  end
end