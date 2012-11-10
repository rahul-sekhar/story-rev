require 'rubygems'
require 'spork'
 
Spork.prefork do
  unless ENV['DRB']
    require 'simplecov'
    SimpleCov.start 'rails'
    SimpleCov.command_name "Cucumber"
  end

  require 'cucumber/rails'
  require 'cucumber/rspec/doubles'

  Capybara.default_selector = :css

  unless ENV['SHOW_BROWSER']
    Before('@javascript') do
      require 'headless'
      headless = Headless.new
      headless.start
    end
  end
end
 
Spork.each_run do
  if ENV['DRB']
    require 'simplecov'
    SimpleCov.start 'rails'
    SimpleCov.command_name "Cucumber"
  end

  ActionController::Base.allow_rescue = false
  
  DatabaseCleaner.strategy = :transaction

  Cucumber::Rails::Database.javascript_strategy = :truncation

  at_exit do
    FileUtils.rm_rf(Dir["#{Rails.root}/tmp/tests"])
  end
end
