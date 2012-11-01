require 'spec_helper'

describe "Browse Store" do
  describe "View store with a few books" do
    before do
      book1 = Book.create(title: "Test Book", author_name: "Test Author")
      edition1 = book1.editions.create(format_name: "Hardbound")
      edition1.used_copies.create(price: 50)

      book2 = Book.create(title: "Other Book", author_name: "Some Author")
      edition2 = book2.editions.create(format_name: "Softbound")
      edition2.new_copies.create(price: 100, stock: 1)

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