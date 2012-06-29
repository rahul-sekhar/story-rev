require 'spec_helper'

describe Illustrator do
  let(:person) { create(:illustrator) }

  def create_person(params = {})
    create(:illustrator, params)
  end

  it_should_behave_like "a person"
end