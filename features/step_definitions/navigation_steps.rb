Given /^I have logged in as an admin$/ do
  step "the standard admin roles exist"
  visit admin_login_path
  step 'I enter the password "admin_pass"'
  #fill_in 'Password', with: 'admin_pass'
  #click_button 'Sign In'
end

Given /^I am on (.*?)$/ do |arg1|
  visit path_to(arg1)
end

When /^I go to (.*?)$/ do |arg1|
  visit path_to(arg1)
end

Then /^I should be on (.*?)$/ do |arg1|
  current_path.should == path_to(arg1)
end

When /^I enter the password "(.*?)"$/ do |arg1|
  fill_in 'Password', with: arg1
  click_button 'Sign In'
end

When /^I search for "(.*?)"$/ do |arg1|
  fill_in "token-input-book-search", with: arg1
end

Then /^I should see "(.*?)"$/ do |arg1|
  page.should have_content(arg1)
end
