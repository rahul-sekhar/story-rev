require 'spec_helper'

describe BookSearcher do
  it "should initialise with a nil query" do
    BookSearcher.new.should be_a BookSearcher
  end

  describe "#search" do
    describe "by title:" do
      before do
        @book1 = create(:book, title: "The Little Brown Dog")
        @book2 = create(:book, title: "Brown Cows")
        @book3 = create(:book, title: "Owner of the Mansion")
      end
      
      it "should return an empty array when the query does not match any title" do
        BookSearcher.search("cat").results.should be_empty
      end

      it "should ignore a blank or space filled query" do
        BookSearcher.search("").results.should be_empty
        BookSearcher.search(" ").results.should be_empty
      end

      it "should return books with the query contained in the title" do
        x = BookSearcher.search("Brown")
        x.results.should include @book1, @book2
        x.results.length.should == 2
      end

      it "should work case insensitively" do
        BookSearcher.search("BROWN").results.length.should == 2
      end

      it "should escape SQL wildcards" do
        BookSearcher.search("bro%").results.should be_empty
      end

      it "should only match the query from the beginning of each word in the title" do
        x = BookSearcher.search("own")
        x.results.should include @book3
        x.results.length.should == 1
      end
    end

    describe "by author name:" do
      before do
        @book1 = create(:book, author_name: "William Brown")
        @book2 = create(:book, author_name: "Rowan Atkinson")
        @book3 = create(:book, author_name: "Brody Smith")
        @book4 = create(:book, author_name: "Smith")
      end

      it "should return return books with the query contained in the author name" do
        x = BookSearcher.search("bro")
        x.results.should include @book1, @book3
        x.results.length.should == 2
      end

      it "should work for authors with a single name" do
        x = BookSearcher.search("smith")
        x.results.should include @book3, @book4
        x.results.length.should == 2
      end

      it "should only match the query from the beginning of each word" do
        x = BookSearcher.search("row")
        x.results.should include @book2
        x.results.length.should == 1
      end

      it "should match both author names and titles" do
        @book2.title = "Brown Sugar"
        @book2.save
        x = BookSearcher.search("brown")
        x.results.should include @book1, @book2
        x.results.length.should == 2
      end
    end

    describe "by accession_id:" do
      before do
        author = create(:author, name: "Some Author")
        @book1 = create(:book, title: "Book 1", author: author, accession_id: 50)
        @book2 = create(:book, title: "Book 2", author: author, accession_id: 506)
        @book3 = create(:book, title: "Book 3", author: author, accession_id: 12)
      end
      
      it "should match accession ids" do
        x = BookSearcher.search("5")
        x.results.should include @book1, @book2
        x.results.length.should == 2
      end
    end
  end
  
  describe "formatted search results" do
    def mocked_searcher(results, query = "some query")
      searcher = BookSearcher.new(query)
      searcher.stub(:do_search).and_return(results)
      return searcher.search
    end

    it "should return a hash containing book ids and text" do
      results = mocked_searcher(build_list(:book, 2)).formatted_results
      results.length.should == 2
      results.first.should have_key :id
      results.first.should have_key :text
    end

    it "should return the correct book ID" do
      book1 = create(:book)
      results = mocked_searcher([book1]).formatted_results
      results.first[:id].should == book1.id
    end

    it "should return the book title as the text by default" do
      book1 = create(:book)
      results = mocked_searcher([book1]).formatted_results
      results.first[:text].should == book1.title
    end

    context "in the case of an author match" do
      it "should return the author name along with the title as the text" do
        book1 = create(:book, :author_name => "William Tell")
        results = mocked_searcher([book1], "will").formatted_results
        results.first[:text].should include book1.author_name
        results.first[:text].should include book1.title
      end
    end

    context "in the case of an accession ID match" do
      it "should return the author name along with the title as the text" do
        book1 = create(:book, :accession_id => 37)
        results = mocked_searcher([book1], "3").formatted_results
        results.first[:text].should include book1.accession_id.to_s
        results.first[:text].should include book1.title
      end
    end
    
    it "should prioritise full title matches over word matches" do
      book1 = build(:book, id: 1, title: "A Title With More Stuff")
      book2 = build(:book, id: 2, title: "A Title")
      searcher = mocked_searcher([book1, book2], "a title")
      searcher.formatted_results.first[:id].should == 2
    end

    it "should prioritise full author matches over word matches" do
      book1 = build(:book, id: 1, author_name: "William Tell")
      book2 = build(:book, id: 2, author_name: "William")
      searcher = mocked_searcher([book1, book2], "william")
      searcher.formatted_results.first[:id].should == 2
    end

    it "should prioritise full accession id matches over partial matches" do
      book1 = build(:book, id: 1, accession_id: 503)
      book2 = build(:book, id: 2, accession_id: 50)
      searcher = mocked_searcher([book1, book2], "50")
      searcher.formatted_results.first[:id].should == 2
    end

    it "should prioritise word title matches over partial matches" do
      book1 = build(:book, id: 1, title: "Brownish Things")
      book2 = build(:book, id: 2, title: "The Brown Cow")
      searcher = mocked_searcher([book1, book2], "brown")
      searcher.formatted_results.first[:id].should == 2
    end

    it "should prioritise word author matches over partial matches" do
      book1 = build(:book, id: 1, author_name: "William Tell")
      book2 = build(:book, id: 2, author_name: "Mr Will Fawkes")
      searcher = mocked_searcher([book1, book2], "Will")
      searcher.formatted_results.first[:id].should == 2
    end
  end
end