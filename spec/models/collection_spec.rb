require 'spec_helper'

describe Collection do
  let(:collection) { build(:collection) }
  let(:max_length) { 200 }

  subject{ collection }
  
  def create_object(params = {})
    create(:collection, params)
  end

  it_should_behave_like "an object with a unique name"
end