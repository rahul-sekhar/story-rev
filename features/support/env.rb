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
  #default_js_driver = :webkit
  #Capybara.javascript_driver = default_js_driver

  Before('@javascript') do
    # Capybara.javascript_driver = :selenium
    require 'headless'
    headless = Headless.new
    headless.start
  end

  # After('@selenium') do
  #   Capybara.javascript_driver = default_js_driver
  # end
end
 
Spork.each_run do
  if ENV['DRB']
    require 'simplecov'
    SimpleCov.start 'rails'
    SimpleCov.command_name "Cucumber"
  end

  ActionController::Base.allow_rescue = false
  
  begin
    DatabaseCleaner.strategy = :transaction
  rescue NameError
    raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
  end

  Cucumber::Rails::Database.javascript_strategy = :truncation

end
