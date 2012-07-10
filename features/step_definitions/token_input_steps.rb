When /^I search for "(.*?)" on the admin book search page$/ do |arg1|
  fill_in "token-input-book-search", with: arg1
end

When /^I click the list item "(.*?)"$/ do |arg1|
  page.find('li', text: arg1).click
end

When /^I fill in "(.*?)" with a new token "(.*?)"$/ do |arg1, arg2|
  field_id = find_field(arg1)[:id]
  fill_in "token-input-#{field_id}", with: arg2
  page.should have_content("Add a new item - #{arg2}")
  page.find('li', text: "Add a new item - #{arg2}").click
end