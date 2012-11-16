require 'spec_helper'

describe PickupPoint do
  let(:pickup_point) { build(:pickup_point) }
  let(:max_length) { 255 }

  subject{ pickup_point }
  
  def create_object(params = {})
    create(:pickup_point, params)
  end

  it_should_behave_like "an object with a unique name"

  describe "#visible" do
    it "is true by default" do
      pickup_point.visible.should == true
    end

    it "cannot be nil" do
      pickup_point.visible = nil
      pickup_point.should be_invalid
    end

    it "can be false" do
      pickup_point.visible = false
      pickup_point.should be_valid
    end

    it "can be true" do
      pickup_point.visible = true
      pickup_point.should be_valid
    end
  end

  describe "scope - visible" do
    it "returns only visible pickup points" do
      p1 = create(:pickup_point)
      p2 = create(:pickup_point, visible: false)
      p3 = create(:pickup_point)

      PickupPoint.visible.should =~ [p1, p3]
    end
  end
end