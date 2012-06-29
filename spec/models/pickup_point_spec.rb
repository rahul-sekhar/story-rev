require 'spec_helper'

describe PickupPoint do
  let(:pickup_point) { build(:pickup_point) }
  let(:max_length) { 255 }

  subject{ pickup_point }
  
  def create_object(params = {})
    create(:pickup_point, params)
  end

  it_should_behave_like "an object with a unique name"
end