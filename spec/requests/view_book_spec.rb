require 'spec_helper'

describe "View book" do
  context "existing book" do
    before do
      book_type = BookType.create(name: "Fiction")
      award_type = AwardType.create(name: "Newberry")
      award1 = Award.create(award_type_id: award_type.id, name: "Runner-up")
      award2 = Award.create(award_type_id: award_type.id, name: "Winner")
      @book = Book.create(
        title: "Test Book",
        author_name: "Random Author",
        illustrator_name: "Some Illustrator",
        publisher_name: "Blah Publishers",
        age_from: 5,
        age_to: 10,
        year: 1989,
        amazon_url: 'http://amazon.com/some-book',
        short_description: "This is a test book\n\nSecond para about the book",
        country_name: "India",
        book_type_id: book_type.id,
        collection_list: "Test books, Random things",
        description_attributes: [{
          title: "Review 1",
          content: "What a great book"
        }, 
        {
          title: "Review 2",
          content: "Lousy book\n\nWouldn't read again"
        }],
        award_attributes: [{
          award_id: award1.id
        },
        {
          award_id: award2.id,
          year: 1765
        }]
      )
    end

    subject { page }

    context "no copies" do
      before do
        visit book_path(@book)
      end

      it "has a path determined by its accession ID" do
        current_path.should eq("/books/#{@book.accession_id}")
      end

      it { should have_css('title', text: 'Story Revolution - Test Book') }

      it { should have_css('h2', text: 'Test Book') }

      it { should have_content('Random Author') }

      it { should have_content('Some Illustrator') }

      it { should have_content('Blah Publishers') }

      it "has the age level" do
        find('.age').text.should match(/5 . 10/)
      end

      it { should have_content('1989') }

      it "should have an amazon link" do
        find('.amazon-link a')['href'].should eq('http://amazon.com/some-book')
      end

      it { should have_content('This is a test book Second para about the book') }

      it { should have_no_content('India') }

      it { should have_no_content('Fiction') }

      it { should have_content('Review 1 What a great book') }

      it { should have_content("Review 2 Lousy book Wouldn't read again") }

      it { should have_content('Newberry Runner-up') }

      it { should have_content('Newberry Winner 1765') }

      it { should have_content('no copies in stock') }

      it { should have_content('Test books') }

      it { should have_content('Random things') }
    end

    context "with copies" do
      before do
        edition = @book.editions.create(name: "That Edition", format_name: "Softbound")
        edition.used_copies.create(price: 50)
        edition.used_copies.create(price: 70)

        new_copy = edition.new_copies.create(price: 200, stock: 1)

        visit book_path(@book)
      end

      it "should contain the used copy information" do
        within '.used-copies' do
          page.should have_content("Softbound")
          page.should have_content("50")
          page.should have_content("70")
        end
      end

      it "should contain the new copy information" do
        within '.new-copies' do
          page.should have_content("Softbound")
          page.should have_content("200")
        end
      end
    end
  end

  context "non-existant book" do
    it "displays a 404 error page" do
      expect { visit "/books/542" }.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end
end