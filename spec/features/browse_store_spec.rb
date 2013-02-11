require 'spec_helper'

describe "Browse Store" do
  describe "View store with a few books" do
    before do
      create(:book_with_used_copy, title: "Test Book", author_name: "Test Author")
      create(:book_with_new_copy, title: "Other Book", author_name: "Some Author")
      visit "/"
    end

    it "shows each book and author" do
      page.should have_content("Test Book")
      page.should have_content("Test Author")

      page.should have_content("Other Book")
      page.should have_content("Some Author")
    end
  end 
end