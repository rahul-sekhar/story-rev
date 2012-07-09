require 'rubygems'
require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do

 ENV["RAILS_ENV"] ||= 'test'
 require File.expand_path("../../config/environment", __FILE__)
 require 'rspec/rails'
 require 'rspec/autorun'

 RSpec.configure do |config|
    config.use_transactional_fixtures = true
    config.infer_base_class_for_anonymous_controllers = false

    config.order = "random"

    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.filter_run :focus => true
    config.filter_run_excluding :skip => true, :server => true
    config.run_all_when_everything_filtered = true
   
    config.after(:all) do
      FileUtils.rm_rf(Dir["#{Rails.root}/tmp/tests"])
    end

    config.include FactoryGirl::Syntax::Methods

    # Allow access to view methods for presenter tests
    # Note that controller helper methods won't be accessible
    config.include ActionView::TestCase::Behavior, 
      example_group: {file_path: %r{spec/presenters}}

    # Pre-loading for performance:
    require 'rspec/mocks'
    require 'rspec/expectations'
    require 'rspec/matchers'
    require 'rspec/core'

    # To help pick files to preload
    # http://www.opinionatedprogrammer.com/2011/02/profiling-spork-for-faster-start-up-time/
    # module Kernel
    #   def require_with_trace(*args)
    #     start = Time.now.to_f
    #     @indent ||= 0
    #     @indent += 2
    #     require_without_trace(*args)
    #     @indent -= 2
    #     Kernel::puts "#{' '*@indent}#{((Time.now.to_f - start)*1000).to_i} #{args[0]}"
    #   end
    #   alias_method_chain :require, :trace
    # end
 end

end

Spork.each_run do
  # Randomise RSpec seed
  RSpec.configuration.seed = srand && srand % 0xFFFF

  # Load support files
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  # Change cover uploader storage directory
  CoverUploader.class_eval do
    def store_dir
      "#{Rails.root}/spec/uploads/books/#{model.id}"
    end
  end
  CoverUploader.enable_processing = false
end