
Feature: User views books in the store

Scenario: Store with no books
Given I am on the home page
Then I should see "No books"

Scenario: Store with a single page of books
Given 5 used copy with books exist
And I am on the home page
Then I should not see "next"
And I should not see "previous"