Feature: Admin manages books

As an admin I want to be able to add and edit book information and delete books

Background:
Given I have logged in as an admin
And the amazon book information is disabled

@javascript
Scenario: Add a book with new items
Given I am on the new book page
And I fill in "Title" with "Scary Book"
And I fill in "Author" with a new token "John Doe"
And I fill in "Illustrator" with a new token "Random Chappie"
And I fill in "Publisher" with a new token "Awesome Books"
And I fill in "Year of Publication" with "2011"
And I fill in "Country" with a new token "Ukraine"
And I fill in "Age level" with "15"
And I fill in "to" with "62"
And I click "Save"
Then a book should exist with the title "Scary Book"
And the book should have the following attributes
| author_name       | John Doe        |
| illustrator_name  | Random Chappie  |
| publisher_name    | Awesome Books   |
| year              | 2011            |
| country_name      | Ukraine         |
| age_from          | 15              |
| age_to            | 62              |