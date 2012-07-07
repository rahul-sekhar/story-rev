Given /^PENDING/ do
  pending
end

Then /^capture the page$/ do
  page.driver.render "tmp/page.png"
end

Then /^show me the page$/ do
  save_and_open_page
end
