Feature: Admin searches for books

As an admin I want to be able to search for books by their title, author, ISBN or accession number so that I can easily find and edit the books

@javascript
Scenario: Search by author name
Given PENDING: test webkit
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
