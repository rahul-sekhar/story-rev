When /^I search for "(.*?)" on the admin book search page$/ do |arg1|
  fill_in "token-input-book-search", with: arg1
end

When /^I click the list item "(.*?)"$/ do |arg1|
  page.find('li', text: arg1).click
end

When /^I add the( new)? token "(.*?)" to "(.*?)"$/ do |new_token, arg1, arg2|
  field_id = find_field(arg2)[:id]
  fill_in "token-input-#{field_id}", with: arg1
  if new_token.present?
    page.find('.token-input-dropdown li', text: /new .* #{arg1}$/).click
  else
    page.find('.token-input-dropdown li', text: /^#{arg1}$/).click
  end
end

When /^I add the following( new)? tokens to "(.*?)":?$/ do |new_tokens, arg2, table|
  field_id = find_field(arg2)[:id]
  field = page.find("#token-input-#{field_id}")
  table.raw.flatten.each do |token|
    field.set(token)
    if new_tokens.present?
      page.find('.token-input-dropdown li', text: /new .* #{token}$/).click
    else
      page.find('.token-input-dropdown li', text: /^#{token}$/).click
    end
  end
end

When /^I add "(.*?)" to the "(.*?)" select list$/ do |arg1, arg2|
  select "Add", from: arg2
  a = page.driver.browser.switch_to.alert
  a.send_keys(arg1)
  a.accept
end

When /^I (enter|add) an award with the( new)? type "(.*?)"(?:,| and) the( new)? name "(.*?)"(?: and the year "(.*?)")?$/ do |arg1, new_award_type, award_type, new_award_name, award_name, year|
  
  click_link "Add award" if arg1 == "add"

  within "#award-field-list li:last-child" do
    if new_award_type.present?
      step "I add \"#{award_type}\" to the \"book_award[award_type_id]\" select list"
    else
      select award_type, from: 'book_award[award_type_id]'
    end

    if new_award_name.present?
      step "I add \"#{award_name}\" to the \"book[award_attributes][][award_id]\" select list"
    else
      select award_name, from: 'book[award_attributes][][award_id]'
    end

    fill_in "book[award_attributes][][year]", with: year if year.present?
  end
end

When /^I (enter|add) a description with the title "(.*?)" and content "(.*?)"$/ do |arg1, title, content|
  within "#description-fields" do
    click_link "+" if arg1 == "add"

    fill_in "description-title", with: title
    fill_in "description-content", with: content
  end
end

Then /^"(.*?)" should be shown to have an error$/ do |arg1|
  page.should have_css '.field_with_errors label', text: arg1
end

When /^I upload a cover image$/ do
  page.execute_script('$("#edit-cover-list").show()')
  click_link "Upload an image"
  attach_file("image_file", "#{Rails.root}/public/images/title.png")
  wait_until { page.has_selector? '.cover img'}
end

Then /^I should see the footer elements$/ do
  step 'I should see "Get In Touch"'
  step 'I should see "Subscribe"'
  step 'I should see "facebook"'
end