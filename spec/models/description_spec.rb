require 'spec_helper'

describe Description do
  let(:description) { create(:description) }
  subject { description }

  context "when the title is nil" do
    before do 
      subject.title = nil
      subject.valid?
    end
    it { should be_invalid }
    its(:errors) { should have_key :title }
  end

  context "when the title is at its maximum length" do
    before { subject.title = 'a' * 255 }
    it { should be_valid }
  end

  context "when the title is above the maximum length" do
    before do 
      subject.title = 'a' * 256
      subject.valid?
    end
    it { should be_invalid }
    its(:errors) { should have_key :title }
  end
end