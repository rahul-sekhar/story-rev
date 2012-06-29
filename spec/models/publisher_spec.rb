require 'spec_helper'

describe Publisher do
  let(:publisher) { build(:publisher) }
  let(:max_length) { 150 }

  subject{ publisher }
  
  def create_object(params = {})
    create(:publisher, params)
  end

  it_should_behave_like "an object with a unique name"
  it_should_behave_like "an object findable by name"
end