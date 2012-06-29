require 'spec_helper'

describe BookType do
  let(:book_type) { build(:book_type) }
  let(:max_length) { 100 }

  subject{ book_type }
  
  def create_object(params = {})
    create(:book_type, params)
  end

  it_should_behave_like "an object with a unique name"
end