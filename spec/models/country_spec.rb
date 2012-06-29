require 'spec_helper'

describe Country do
  let(:country) { build(:country) }
  let(:max_length) { 100 }

  subject{ country }
  
  def create_object(params = {})
    create(:country, params)
  end

  it_should_behave_like "an object with a unique name"
  it_should_behave_like "an object findable by name"
end