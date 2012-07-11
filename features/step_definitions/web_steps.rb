Given /^I am on (.*?)$/ do |arg1|
  visit path_to(arg1)
end

When /^I go to (.*?)$/ do |arg1|
  visit path_to(arg1)
end

Then /^I should be on (.*?)$/ do |arg1|
  current_path.should == path_to(arg1)
end

Then /^I should see "(.*?)"$/ do |arg1|
  page.should have_content(arg1)
end

Then /^the "(.*?)" field should contain "(.*?)"$/ do |arg1, arg2|
  find_field(arg1).value.should == arg2
end

When /^I click "(.*?)"$/ do |arg1|
  click_on arg1
end

When /^I fill in "(.*?)" with "(.*?)"$/ do |arg1, arg2|
  fill_in arg1, with: arg2
end

When /^I select "(.*?)" from "(.*?)"$/ do |arg1, arg2|
  select arg1, from: arg2
end