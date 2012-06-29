require 'spec_helper'

describe Format do
  let(:format) { build(:format) }
  let(:max_length) { 100 }

  subject{ format }
  
  def create_object(params = {})
    create(:format, params)
  end

  it_should_behave_like "an object with a unique name"
  it_should_behave_like "an object findable by name"
end