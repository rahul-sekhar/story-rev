Given /^the amazon book information is disabled$/ do
  AWSInfo.stub(:search).and_return([])
end