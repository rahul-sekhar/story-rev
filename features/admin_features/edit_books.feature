Feature: Admin edits books

As an admin I want to be able to change the information for existing books and delete them.

Background:
Given I have logged in as an admin
And a book exists with information:
| title        | The Wind in the Willows |
| author_name  | Kenneth Grahame         |
And I am on the edit page for that book