require 'spec_helper'

describe EditionPresenter, type: :decorator do
  let(:edition) { build(:edition_with_book) }
  subject {EditionPresenter.new(edition, view)}

  it "gives a valid hash" do
    subject.as_hash.should be_present
    subject.as_hash.should be_a Hash
  end
end