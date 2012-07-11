Feature: Admin manages books

As an admin I want to be able to add and edit book information and delete books

Background:
Given I have logged in as an admin
And the amazon book information is disabled

@javascript
Scenario: Add a book with new attributes
Given I am on the new book page
When I fill in "Title" with "Scary Book"
And I add the new token "John Doe" to "Author"
And I add the new token "Random Chappie" to "Illustrator"
And I add the new token "Awesome Books" to "Publisher"
And I fill in "Year of Publication" with "2011"
And I add the new token "Ukraine" to "Country"
And I fill in "Age level" with "15"
And I fill in "to" with "62"
And I add "Fiction" to the "Book type" select list
And I add the following tokens to "Collections":
| Frightening books | Test books |
And I fill in an award with the new award type "Newberry", the new description "Winner" and the year "1986"
And I add an award with the award type "Newberry" and the new description "Runner Up"
And I fill in "Amazon URL" with "http://www.amazon.com/blahblah"
And I fill in "Short Description" with "It really is a very scary book."
And I enter a description with the title "Review" and content "It's a great book"
And I add a description with the title "Other Review" and content "It's a terribly scary book"
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
| book_type_name    | Fiction         |
And the book should have a collection with the name "Frightening books"
And the book should have a collection with the name "Test books"
