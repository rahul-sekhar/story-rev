require 'active_support/core_ext'

notification :dbus_notify

guard 'spork', :cucumber_env => { 'RAILS_ENV' => 'test' }, :rspec_env => { 'RAILS_ENV' => 'test' } do
  watch('config/application.rb')
  watch('config/environment.rb')
  watch('config/environments/test.rb')
  watch(%r{^config/environments/.+\.rb$})
  watch(%r{^config/initializers/.+\.rb$})
  watch('Gemfile')
  watch('Gemfile.lock')
  watch('spec/spec_helper.rb') { :rspec }
  watch('test/test_helper.rb') { :test_unit }
  watch(%r{features/support/}) { :cucumber }
  watch('spec/support/')
  watch('app/uploaders/')
  watch('db/seeds.rb')
end

guard 'rspec', :version => 2, :all_after_pass => false, :cli => '--drb' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }

  watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^app/(.*)(\.erb|\.haml)$})                 { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
  watch(%r{^app/controllers/(.+)_(controller)\.rb$})  { |m| ["spec/routing/#{m[1]}_routing_spec.rb", "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb", "spec/acceptance/#{m[1]}_spec.rb"] }
  watch(%r{^spec/support/(.+)\.rb$})                  { "spec" }
  watch('config/routes.rb')                           { "spec/routing" }
  watch('app/controllers/application_controller.rb')  { "spec/controllers" }
  
  # Capybara request specs
  watch(%r{^app/views/(.+)/.*\.(erb|haml)$})          { |m| "spec/requests/#{m[1]}_spec.rb" }

  # New copy and used copy depend on copy
  watch('app/models/copy.rb') { ['spec/models/new_copy_spec.rb', 'spec/models/used_copy_spec.rb'] }
  
  # watch(%r{^app/controllers/(.+)_(controller)\.rb$})  do |m|
  #   ["spec/routing/#{m[1]}_routing_spec.rb",
  #    "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb",
  #    "spec/acceptance/#{m[1]}_spec.rb",
  #    (m[1][/_pages/] ? "spec/requests/#{m[1]}_spec.rb" : 
  #                      "spec/requests/#{m[1].singularize}_pages_spec.rb")]
  # end
  # watch(%r{^app/views/(.+)/}) do |m|
  #  "spec/requests/#{m[1].singularize}_pages_spec.rb"
  # end
end