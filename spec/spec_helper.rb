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
    # ## Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr

    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    config.fixture_path = "#{::Rails.root}/spec/fixtures"

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
    config.filter_run_excluding :skip => true
    config.run_all_when_everything_filtered = true

    config.include FactoryGirl::Syntax::Methods

    config.after(:all) do
      FileUtils.rm_rf(Dir["#{Rails.root}/spec/uploads"])
    end

    # Load seeds
    load "#{Rails.root}/db/seeds.rb"
  end

  # Use the webkit driver for javascript in capybara
  Capybara.javascript_driver = :webkit
end

Spork.each_run do
  FactoryGirl.reload
  ActiveSupport::Dependencies.clear
  ActiveRecord::Base.instantiate_observers

  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  CoverUploader.class_eval do
    def store_dir
      "#{Rails.root}/spec/uploads/books/#{model.id}"
    end 
  end
  CoverUploader.enable_processing = false
end
