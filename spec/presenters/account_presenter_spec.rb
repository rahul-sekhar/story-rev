require 'spec_helper'

describe AccountPresenter, type: :decorator do
  let(:account){ build(:account) }
  subject {AccountPresenter.new(account, view)}

  it "gives a valid hash form" do
    subject.as_hash.should be_present
    subject.as_hash.should be_a Hash
  end
end