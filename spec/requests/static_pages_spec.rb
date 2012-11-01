require 'spec_helper'

describe "Static Pages" do
  shared_examples("page with header and footer") do
    describe "page footer" do
      it "has a get in touch section" do
        within '#page-footer' do
          page.should have_content('Get In Touch')
        end
      end

      it "has a subscribe section" do
        within '#page-footer' do
          page.should have_content('Subscribe')
        end
      end
    end

    describe "page header" do
      it "has the title" do
        within '#page-header' do
          page.should have_css('h1', text: 'Story Revolution')
        end
      end

      it "has a shopping cart link" do
        within '#page-header' do
          page.should have_link('Your Cart')
        end
      end

      it "has a store link" do
        within '#page-header' do
          page.should have_link('Bookstore')
        end
      end

      it "has an about link" do
        within '#page-header' do
          page.should have_link('About Us')
        end
      end

      it "has a help link" do
        within '#page-header' do
          page.should have_link('Help')
        end
      end
    end
  end

  describe "Store without books" do
    before do
      visit '/'
    end

    it "indicates that there are no books" do
      page.should have_content('No books found')
    end
    
    it "has the right title" do
      page.find(:css, 'title').text.should eq("Story Revolution - Store")
    end

    it "has a filters section" do
      page.should have_content('Filters')
    end

    it_behaves_like("page with header and footer")
  end

  describe "About page" do
    before do
      visit '/about'
    end

    it "has the founders" do
      page.should have_content "Founders"
      page.should have_content "Angela Jain"
      page.should have_content "Shalini Sekhar"
    end

    it "has the right title" do
      page.find(:css, 'title').text.should eq("Story Revolution - About")
    end

    it_behaves_like("page with header and footer")
  end

  describe "Help page" do
    before do
      visit '/help'
    end

    it "has the right title" do
      page.find(:css, 'title').text.should eq("Story Revolution - Help")
    end

    it "has various help titles" do
      page.should have_content "Postage"
      page.should have_content "Payment"
      page.should have_content "Condition"
      page.should have_content "Return"
      page.should have_content "Cancellation"
    end

    it_behaves_like("page with header and footer")
  end
end