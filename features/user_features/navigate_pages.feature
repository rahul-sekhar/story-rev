Feature: User navigates the pages available

As a user I want to view the various pages of the book store so that I can find the information that I need.

Scenario: Go to the about page from the home page
Given I am on the home page
When I click "About Us"
Then I should be on the about page
And the page should have the title "Story Revolution - About"
And I should see "Founders"
And I should see "Shalini Sekhar"
And I should see "Angela Jain"
And I should see the footer elements

Scenario: Go to the help page from the home page
Given I am on the home page
When I click "Help"
Then I should be on the help page
And the page should have the title "Story Revolution - Help"
And I should see "Postage"
And I should see "Payment"
And I should see "Condition"
And I should see "Return"
And I should see "Cancellation"
And I should see the footer elements

Scenario: Go to the home page from the about page
Given I am on the about page
When I click "Bookstore"
Then I should be on the home page
And the page should have the title "Story Revolution - Store"
And I should see the footer elements

Scenario: Go to the help page from the about page
Given I am on the about page
When I click "Help"
Then I should be on the help page

Scenario: Go to the home page from the help page
Given I am on the help page
When I click "Bookstore"
Then I should be on the home page

Scenario: Go to the about page from the help page
Given I am on the help page
When I click "About"
Then I should be on the about page