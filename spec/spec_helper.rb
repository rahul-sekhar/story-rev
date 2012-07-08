require 'rubygems'
require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do

  ENV["RAILS_ENV"] ||= 'test'

  require File.expand_path("../../config/environment", __FILE__)

  require 'rspec/rails'
  require 'rspec/autorun'
  require 'draper/rspec_integration'

  RSpec.configure do |config|
    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = true

    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false

    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.filter_run :focus => true
    config.filter_run_excluding :skip => true, :server => true
    config.run_all_when_everything_filtered = true

    config.include FactoryGirl::Syntax::Methods

    config.after(:all) do
      FileUtils.rm_rf(Dir["#{Rails.root}/spec/uploads"])
    end
  end

  Capybara.javascript_driver = :webkit
end

Spork.each_run do
  
  ActiveSupport::Dependencies.clear
  ActiveRecord::Base.instantiate_observers
  FactoryGirl.reload

  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  CoverUploader.class_eval do
    def store_dir
      "#{Rails.root}/spec/uploads/books/#{model.id}"
    end
  end
  CoverUploader.enable_processing = false
end
