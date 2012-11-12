source 'http://rubygems.org'

gem 'rails', '3.2.8'
gem 'pg', '0.14.1'

group :development do
  gem 'thin', '1.5.0'
  gem 'rvm-capistrano', '1.2.7'
end

gem 'strip_attributes', '1.1.1'
gem 'jquery-rails', '2.1.3'
gem 'sanitize', '2.0.3'
gem 'yaml_db', '0.2.3'
gem 'kaminari', '0.14.1'
gem 'carrierwave', '0.7.0'
gem 'rmagick', '2.13.1'
gem 'simple_form', '2.0.4'
gem 'amazon-ecs', '2.2.4'
gem 'terminator', '0.4.4'
gem 'valid_email', '0.0.4', :require => 'valid_email/email_validator'
gem 'delayed_job_active_record', '0.3.3'
gem 'daemons', '1.1.9'
gem 'whenever', '0.7.3'
gem 'aws-s3', '0.6.3'
gem 'squeel', '1.0.13'
gem 'bcrypt-ruby', '~> 3.0.0', :require => "bcrypt"

group :assets do
  gem 'sass-rails', '3.2.5'
  gem 'uglifier', '1.3.0'
end

group :test, :development do
  gem 'rspec-rails', '2.11.4'
  gem 'cucumber-rails', '1.3.0', :require => false
  gem 'database_cleaner', '0.9.1'
  gem 'spork-rails', '3.2.0'
end

group :test do
  gem 'factory_girl_rails', '4.1.0'
  gem 'pickle', '0.4.11'
  gem 'capybara', '1.1.2'
  gem 'launchy', '2.1.2'
  gem 'headless', '0.3.1'
  gem 'simplecov', '0.7.1', :require => false
end

group :test, :development do
  gem 'libnotify', '0.8.0'
  gem 'ruby-dbus', '0.8.0'
  # Using a modified guard to fix growl notifications on Ubuntu
  gem 'guard', git: 'git://github.com/rahul-sekhar/guard.git'
  gem 'guard-spork', '1.1.0'
  gem 'guard-rspec', '1.1.0'
  gem 'guard-cucumber', '1.2.0'
end
