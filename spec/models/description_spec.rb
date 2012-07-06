require 'spec_helper'

describe Description do
  let(:description) { create(:description) }
  subject { description }

  it "should require a title" do
    subject.title = ""
    subject.should be_invalid
    subject.errors.should have_key :title
  end

  it "should be valid when the title is at its maximum length" do
    subject.title = 'a' * 255
    subject.should be_valid
  end

  it "should be invalid when the title is above the maximum length" do
    subject.title = 'a' * 256
    subject.should be_invalid
    subject.errors.should have_key :title
  end
end