When /^I search for "(.*?)" on the admin book search page$/ do |arg1|
  fill_in "token-input-book-search", with: arg1
end

When /^I click the list item "(.*?)"$/ do |arg1|
  page.find('li', text: arg1).click
end

When /^I add the token "(.*?)" to "(.*?)"$/ do |arg1, arg2|
  field_id = find_field(arg2)[:id]
  fill_in "token-input-#{field_id}", with: arg1
  page.find('.token-input-dropdown li', text: /#{arg1}$/).click
end

When /^I add the following tokens to "(.*?)":?$/ do |arg1, table|
  field_id = find_field(arg1)[:id]
  field = page.find("#token-input-#{field_id}")
  table.raw[0].each do |token|
    field.set(token)
    page.find('.token-input-dropdown li', text: /#{token}$/).click
  end
end

When /^I add "(.*?)" to the "(.*?)" select list$/ do |arg1, arg2|
  select "Add", from: arg2
  a = page.driver.browser.switch_to.alert
  a.send_keys(arg1)
  a.accept
end
