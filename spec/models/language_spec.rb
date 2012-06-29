require 'spec_helper'

describe Language do
  let(:language) { build(:language) }
  let(:max_length) { 100 }

  subject{ language }
  
  def create_object(params = {})
    create(:language, params)
  end

  it_should_behave_like "an object with a unique name"
  it_should_behave_like "an object findable by name"
end