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
And I add the following new tokens to "Collections":
| Frightening books | Test books |
And I enter an award with the new type "Newberry", the new name "Winner" and the year "1986"
And I add an award with the type "Newberry" and the new name "Runner Up"
And I fill in "Amazon URL" with "http://www.amazon.com/blahblah"
And I fill in "Short description" with "It really is a very scary book."
And I enter a description with the title "Review" and content "It's a great book"
And I add a description with the title "Other Review" and content "It's a terribly scary book"
And I click "Save"
Then a book should exist with the title "Scary Book"
And the book should have the following attributes
| author_name       | John Doe                        |
| illustrator_name  | Random Chappie                  |
| publisher_name    | Awesome Books                   |
| year              | 2011                            |
| country_name      | Ukraine                         |
| age_from          | 15                              |
| age_to            | 62                              |
| book_type_name    | Fiction                         |
| amazon_url        | http://www.amazon.com/blahblah  |
| short_description | It really is a very scary book. |
And the book should have a collection with the name "Frightening books"
And the book should have a collection with the name "Test books"
And the book should have an award with the name "Newberry Winner 1986"
And the book should have an award with the name "Newberry Runner Up"
And the book should have a description with the title "Review" and content "It's a great book"
And the book should have a description with the title "Other Review" and content "It's a terribly scary book"


@javascript
Scenario: Add a book with pre-existing attributes
Given an author exists with name: "J R R Tolkien"
And an illustrator exists with name: "Sauron"
And a publisher exists with name: "Hobbit Publishers"
And a country exists with name: "England"
And a book type exists with name: "Fantasy"
And a collection exists with name: "Trilogy books"
And an award exists with the type "Newberry" and the name "Winner"
And I am on the new book page
When I fill in "Title" with "Lord of the Rings"
And I add the token "J R R Tolkien" to "Author"
And I add the token "Sauron" to "Illustrator"
And I add the token "Hobbit Publishers" to "Publisher"
And I add the token "England" to "Country"
And I select "Fantasy" from "Book type"
And I add the following tokens to "Collections":
| Trilogy books |
And I add the following new tokens to "Collections":
| Test books |
And I enter an award with the type "Newberry" and the name "Winner"
And I click "Save"
Then a book should exist with the title "Lord of the Rings"
And the book should have the following attributes
| author_name       | J R R Tolkien     |
| illustrator_name  | Sauron            |
| publisher_name    | Hobbit Publishers |
| country_name      | England           |
| book_type_name    | Fantasy           |
And the book should have a collection with the name "Trilogy books"
And the book should have a collection with the name "Test books"
And the book should have an award with the name "Newberry Winner"


@current
Scenario: Add a book with no title
Given I am on the new book page
When I click "Save"
Then I should be on the new book page
And "Title" should be shown to have an error