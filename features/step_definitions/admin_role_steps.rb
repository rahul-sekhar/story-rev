Given /^the standard admin roles exist$/ do
  ar = Admin::Role.new
  ar.name = 'admin',
  ar.password = 'admin_pass'
  ar.save(validate: false)

  ar = Admin::Role.new
  ar.name = 'team',
  ar.password = 'team_pass'
  ar.save(validate: false)
end

When /^I enter the password "(.*?)"$/ do |arg1|
  fill_in 'Password', with: arg1
  click_button 'Sign In'
end

Given /^I have logged in as an admin$/ do
  step "the standard admin roles exist"
  visit admin_login_path
  step 'I enter the password "admin_pass"'
end