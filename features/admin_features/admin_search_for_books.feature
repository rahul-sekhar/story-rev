Feature: Admin searches for books

As an admin I want to be able to search for books so that I can quickly go to a book's edit page, and I want to be able to add a book with a title I type in.

@javascript
Scenario: Search for a book
Given the following books exist
| title                 | author_name    | accession_id |
| Rascal                | Sterling North | 1            |
| The River Between Us  | Richard Peck   | 2            |
| Manic Magee           | Jerry Spinelli | 25           |
| Stargirl              | Jerry Spinelli | 31           |
And I have logged in as an admin
And I am on the admin book search page
When I search for "jerry"
Then I should see "Manic Magee"
And I should see "Stargirl"
When I click the list item "Manic Magee"
Then I should be on the edit page for the book "Manic Magee"

@javascript
Scenario: Add a book
Given I have logged in as an admin
And I am on the admin book search page
When I search for "Scary book"
Then I should see "Add a new book - Scary book"
When I click the list item "Add a new book - Scary book"
Then I should be on the new book page
And show me the page
And the "Title" field should contain "Scary book"