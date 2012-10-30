Feature: User views books in the store

As a user I want to view what books are available in the store so that I know what choices I have

Scenario: Store with no books
Given I am on the home page
Then I should see "No books"

Scenario: Store with a single page of books
Given 5 used copy with books exist
And I am on the home page
Then I should not see "next"
And I should not see "previous"

@current
Scenario: Store with many pages of books
Given 30 used copy with books exist
And I am on the home page
Then I should see the css selector ".current.page" with text "1"
When I click "Next"
Then I should see the css selector ".current.page" with text "2"
When I click "Prev"
Then I should see the css selector ".current.page" with text "1"