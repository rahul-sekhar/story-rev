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

  it "should destroy child awards on being deleted" do
    award_type.save
    create(:award, award_type: award_type)
    expect{ award_type.destroy }.to change{ Award.count }.by(-2)
  end

  it "should destroy child book awards on being deleted" do
    award_type.save
    award = create(:award, award_type: award_type)
    create(:book_award, book: create(:book), award: award)
    expect{ award_type.destroy }.to change{ BookAward.count }.by(-1)
  end
end