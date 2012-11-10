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
    before { award.award_type.name = "Award Type" }
    subject { award.full_name }

    it "should be the award type and award name together" do
      award.name = "Award"
      subject.should == "Award Type Award"
    end

    it "should be only the award type name when the award name is '-'" do
      award.name = "-"
      subject.should == "Award Type"
    end
  end


  it "should require an award" do
    award.award_type = nil
    award.should be_invalid
    award.errors[:award_type].should be_present
  end

  it "should destroy child book awards on being deleted" do
    award.save
    create(:book_award_with_book, award: award)
    expect{ award.destroy }.to change{ BookAward.count }.by(-1)
  end
end