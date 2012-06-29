require "spec_helper"

describe Award do
  let(:award) { build(:award) }
  let(:max_length) { 150 }

  subject{ award }

  def create_object(params = {})
    params = { award_type: award.award_type }.merge(params)
    create(:award, params)
  end

  it_should_behave_like "an object with a unique name"

  context "with another object created for a different award type" do
    before do
      create_object(name: "Object", award_type: create(:award_type))
    end

    context "when its name is the same" do
      before { subject.name = "Object" }
      it { should be_valid }
    end
  end

  describe "full name" do
    before do
      award.award_type.name = "Award Type"
      award.name = "Award"
    end

    subject { award.full_name }

    it "should be the award type and award name together" do
      should == "Award Type Award"
    end

    context "when the award name is '-'" do
      before { award.name = "-" }
      it "should be only the award type name" do
        should == "Award Type"
      end
    end
  end
end