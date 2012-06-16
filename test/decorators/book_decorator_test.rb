require 'test_helper'

class BookDecoratorTest < ActiveSupport::TestCase
  def setup
    ApplicationController.new.set_current_view_context
  end
end
