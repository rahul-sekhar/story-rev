require 'spec_helper'

describe AwardType do
  let(:award_type) { build(:award_type) }
  let(:max_length) { 100 }

  subject{ award_type }
  
  def create_object(params = {})
    create(:award_type, params)
  end

  it_should_behave_like "an object with a unique name"

  context "after being created" do
    before { subject.save }
    it "should have an award with name '-'" do
      subject.awards.length.should == 1
      subject.awards.first.name.should == "-"
    end

    it "should not automatically add any more awards on being saved again" do
      expect{ subject.save }.to change{ subject.awards.length }.by(0)
    end
  end

  context "with child awards" do
    before do
      (1..2).each do |n|
        award_type.awards << Award.new(name: "Award #{n}")
      end
      award_type.save
    end

    it "should destroy all child awards on being deleted" do
      expect{ award_type.destroy }.to change{ Award.count }.by(-2)
    end
  end
end