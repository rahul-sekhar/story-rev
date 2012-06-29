require 'spec_helper'

describe Author do
  let(:person) { create(:author) }

  def create_person(params = {})
    create(:author, params)
  end

  it_should_behave_like "a person"
end