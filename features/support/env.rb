require 'rubygems'
require 'spork'
 
Spork.prefork do
  require 'cucumber/rails'
  require 'capybara/poltergeist'

  Capybara.default_selector = :css
  #default_js_driver = :webkit
  #Capybara.javascript_driver = default_js_driver

  Before('@selenium') do
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
  ActionController::Base.allow_rescue = false
  
  begin
    DatabaseCleaner.strategy = :transaction
  rescue NameError
    raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
  end

  Cucumber::Rails::Database.javascript_strategy = :truncation

end
