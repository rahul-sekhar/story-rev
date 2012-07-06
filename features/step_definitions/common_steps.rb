Given /^PENDING/ do
  pending
end

Then /^capture the page$/ do
  page.driver.render "tmp/page.png"
end

Then /^show me the page$/ do
  save_and_open_page
end

When /^I click the blah button$/ do
  click_button "blah"
end

When /^I fill in "(.*?)"/ do |arg1|
  fill_in "gah", with: arg1
end
