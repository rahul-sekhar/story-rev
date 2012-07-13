Feature: Admin logs in to the backend

As an administrator I want to be able to access the administrative interface only if I enter the correct password so that I can manage and view data and unauthoized users cannot.

Background: Admin Roles
Given the standard admin roles exist

Scenario: Admin interface should require password
When I go to the admin page
Then I should be on the admin login page
And I should see "You must sign in first"

Scenario: Login as admin
Given I am on the admin login page
When I enter the password "admin_pass"
Then I should be on the admin page

Scenario: Invalid login
Given I am on the admin login page
When I enter the password "some_pass"
Then I should be on the admin login page
And I should see "Invalid password"
