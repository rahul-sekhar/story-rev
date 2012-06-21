require 'spec_helper'

describe "Pages" do
  describe "About page" do
    it "should be reachable from the home page" do
      visit '/'
      click_link('About Us')
      current_path.should == about_path
      current_path.should == "/about"
    end

    it "should have the header, navigation and shopping cart" do
      visit about_path
      page.should have_selector("h1", :text => "Story Revolution")
      page.should have_selector(".navigation")
    end

    it "should navigate to the store page" do
      visit about_path
      click_link("Bookstore")
      current_path.should == root_path
    end

    it "should navigate to the help page" do
      visit about_path
      click_link("Help")
      current_path.should == help_path
    end

    it "should navigate to the shopping cart" do
      visit about_path
      page.should have_link("Your Cart")

      # TODO: visit shopping cart page
    end

    it "should have the right title" do
      visit about_path
      page.should have_selector("title", :text => "Story Revolution - About")
    end

    it "should have the about page content" do
      visit about_path
      page.should have_selector("h3", :text => "Story Revolution")
      page.should have_selector("h3", :text => "Founders")
      page.should have_selector("h3", :text => "Team")
      page.should have_selector("h3", :text => "Advisory Help")
      page.should have_selector("h3", :text => "What we look for")
    end

    it "should contain the footer" do
      visit about_path
      page.should have_selector("#page-footer")
      find('#page-footer').should have_content("Subscribe")
      find('#page-footer').should have_content("Get In Touch")
    end
  end
end
