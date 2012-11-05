require 'spec_helper'

describe BookFilter, :focus do
  describe "#filter" do
    subject { BookFilter.filter(params) }

    context "no filter parameters" do
      let(:params) {{}}

      it "is empty with no books" do
        subject.should be_empty
      end

      it "is empty with only unstocked books" do
        create(:book)
        b1 = create(:book)
        e = create(:edition, book: b1)
        create(:new_copy, edition: e)
        b2 = create(:book_with_used_copy)
        c = b2.used_copies.first
        c.stock = 0
        c.save

        subject.should be_empty
      end

      it "returns all stocked books" do
        create_list(:book, 2)
        b1 = create(:book_with_used_copy)
        b2 = create(:book_with_new_copy)
        subject.should == [b1, b2]
      end 
    end

    context "nonsensical parameters" do
      let(:params) {{blah: "eh", num: 123}}
      
      it "is empty with no books" do
        subject.should be_empty
      end

      it "returns all stocked books" do
        create(:book)
        b1 = create(:book_with_used_copy)
        b2 = create(:book_with_new_copy)
        subject.should == [b1, b2]
      end 
    end

    context "invalid parameters" do
      let(:params) {{ author: "eh", format: "blah", publisher: "ah" }}

      it "is empty" do
        b1 = create(:book_with_used_copy)
        b2 = create(:book_with_new_copy)
        subject.should be_empty
      end 
    end

    # Single parameter filtering
    describe "filter by collection" do
      let(:params) {{ collection: "3" }}
      let(:unmatched_coll) { create(:collection, id: 4) }
      let(:matched_coll) { create(:collection, id: 3) }

      it "is empty for a non-existant collection" do
        create(:book_with_used_copy)
        subject.should be_empty
      end

      it "is empty with no matching books" do
        b = create(:book_with_used_copy, collections: [unmatched_coll])
        subject.should be_empty
      end

      it "returns any matching books" do
        b1 = create(:book_with_used_copy, collections: [matched_coll])
        b2 = create(:book_with_new_copy, collections: [matched_coll])
        b3 = create(:book_with_used_copy, collections: [unmatched_coll])
        subject.should =~ [b1, b2]
      end

      it "returns matching books with multiple collections once" do
        b = create(:book_with_used_copy, collections: [matched_coll, unmatched_coll])
        subject.should == [b]
      end
    end

    describe "filter by publisher" do
      let(:params) {{ publisher: "3" }}
      let(:unmatched_pub) { create(:publisher, id: 5) }
      let(:matched_pub) { create(:publisher, id: 3) }
      
      it "is empty for a non-existant publisher" do
        create(:book_with_new_copy)
        subject.should be_empty
      end

      it "is empty with no matching books" do
        create(:book_with_used_copy, publisher: unmatched_pub)
        b = create(:book)
        create(:edition_with_new_copy, publisher: unmatched_pub, book: b)
        subject.should be_empty
      end

      it "returns any matching books" do
        b1 = create(:book_with_used_copy, publisher: matched_pub)
        b2 = create(:book_with_used_copy, publisher: unmatched_pub)
        b3 = create(:book)
        create(:edition_with_new_copy, publisher: matched_pub, book: b3)
        b4 = create(:book)
        create(:edition_with_new_copy, publisher: unmatched_pub, book:b4)
        subject.should =~ [b1,b3]
      end

      it "returns a book with a non-matching book publisher and one matching edition publisher" do
        b = create(:book, publisher: unmatched_pub)
        create(:edition_with_used_copy, publisher: unmatched_pub, book: b)
        create(:edition_with_used_copy, publisher: matched_pub, book: b)
        subject.should == [b]
      end

      it "returns a book with multiple matching edition publishers once" do
        b = create(:book)
        create(:edition_with_used_copy, publisher: matched_pub, book: b)
        create(:edition_with_used_copy, publisher: matched_pub, book: b)
        subject.should == [b]
      end

      it "returns a book with a matching book publisher but non-matching edition publishers" do
        b = create(:book, publisher: matched_pub)
        create(:edition_with_new_copy, publisher: unmatched_pub, book: b)
        p = create(:publisher, id: 8)
        create(:edition_with_new_copy, publisher: p, book: b)
        subject.should == [b]
      end

      it "doesn't return an out of stock edition with a matching publisher" do
        b = create(:book)
        e = create(:edition, publisher: matched_pub)
        subject.should be_empty
      end
    end

    describe "filter by author" do
      let(:params) {{ author: "3" }}
      let(:unmatched_author) { create(:author, id: 5) }
      let(:matched_author) { create(:author, id: 3) }
      
      it "is empty for a non-existant author" do
        create(:book_with_new_copy)
        subject.should be_empty
      end

      it "is empty with no matching books" do
        create(:book_with_used_copy, author: unmatched_author)
        subject.should be_empty
      end

      it "returns any matching books" do
        b1 = create(:book_with_used_copy, author: matched_author)
        b2 = create(:book_with_used_copy, author: unmatched_author)
        b3 = create(:book_with_new_copy, author: matched_author)
        subject.should =~ [b1,b3]
      end
    end

    describe "filter by illustrator" do
      let(:params) {{ illustrator: "3" }}
      let(:unmatched_illustrator) { create(:illustrator, id: 5) }
      let(:matched_illustrator) { create(:illustrator, id: 3) }
      
      it "is empty for a non-existant illustrator" do
        create(:book_with_new_copy)
        subject.should be_empty
      end

      it "is empty with no matching books" do
        create(:book_with_used_copy, illustrator: unmatched_illustrator)
        subject.should be_empty
      end

      it "returns any matching books" do
        b1 = create(:book_with_used_copy, illustrator: matched_illustrator)
        b2 = create(:book_with_used_copy, illustrator: unmatched_illustrator)
        b3 = create(:book_with_new_copy, illustrator: matched_illustrator)
        subject.should =~ [b1,b3]
      end
    end

    describe "filter by book type" do
      context "filter by new" do
        let(:params) {{ type: "new" }}

        it "is empty with only used books" do
          create_list(:book_with_used_copy, 2)
          subject.should be_empty
        end

        it "returns any new books" do
          b = create_list(:book_with_new_copy, 2)
          create(:book_with_used_copy)
          subject.should =~ b
        end

        it "does not return unstocked new books" do
          b1 = create(:book_with_new_copy)
          b2 = create(:book_with_new_copy)
          c = b2.new_copies.first
          c.stock = 0
          c.save
          subject.should == [b1]
        end

        it "returns books with both new and used copies in the same edition" do
          create(:book_with_used_copy)
          b = create(:book_with_used_copy)
          create(:new_copy, edition:b.editions.first, stock:1)
          subject.should == [b]
        end

        it "returns books with both new and used copies in different editions" do
          b = create(:book_with_used_copy)
          create(:edition_with_new_copy, book: b)
          subject.should == [b]
        end

        it "does not return a book with a used copy and unstocked new copy" do
          b = create(:book_with_used_copy)
          create(:new_copy, edition:b.editions.first, stock:0)
          subject.should be_empty
        end
      end
      
      context "filter by used" do
        let(:params) {{ type: "used" }}

        it "is empty with only new books" do
          create_list(:book_with_new_copy, 2)
          subject.should be_empty
        end

        it "returns any used books" do
          b = create_list(:book_with_used_copy, 2)
          create(:book_with_new_copy)
          subject.should =~ b
        end

        it "does not return unstocked new books" do
          b1 = create(:book_with_used_copy)
          b2 = create(:book_with_used_copy)
          c = b2.used_copies.first
          c.stock = 0
          c.save
          subject.should == [b1]
        end

        it "returns books with both new and used copies in the same edition" do
          create(:book_with_new_copy)
          b = create(:book_with_new_copy)
          create(:used_copy, edition:b.editions.first)
          subject.should == [b]
        end

        it "returns books with both new and used copies in different editions" do
          b = create(:book_with_new_copy)
          create(:edition_with_used_copy, book: b)
          subject.should == [b]
        end

        it "does not return a book with a used copy and unstocked new copy" do
          b = create(:book_with_new_copy)
          create(:used_copy, edition:b.editions.first, stock:0)
          subject.should be_empty
        end
      end
    end

    describe "filter by format" do
      let(:params) {{ format: "3" }}
      let(:unmatched_format) { create(:format, id: 5) }
      let(:matched_format) { create(:format, id: 3) }
      
      it "is empty for a non-existant format" do
        create(:book_with_new_copy)
        subject.should be_empty
      end

      it "is empty with no matching books" do
        b = create(:book)
        create(:edition_with_used_copy, book: b, format: unmatched_format)
        subject.should be_empty
      end

      it "returns any matching books" do
        b1 = create(:book)
        create(:edition_with_used_copy, format: matched_format, book: b1)
        b2 = create(:book)
        create(:edition_with_used_copy, format: unmatched_format, book: b2)
        b3 = create(:book)
        create(:edition_with_new_copy, format: matched_format, book: b3)
        subject.should =~ [b1,b3]
      end

      it "returns books with multiple editions, one of which matches" do
        b = create(:book)
        create(:edition_with_new_copy, format: unmatched_format, book: b)
        create(:edition_with_new_copy, format: matched_format, book: b)
        subject.should == [b]
      end

      it "returns one book when more than one of its editions match" do
        b = create(:book)
        create(:edition_with_new_copy, format: matched_format, book: b)
        create(:edition_with_new_copy, format: matched_format, book: b)
        subject.should == [b]
      end

      it "ignores unstocked editions" do
        b = create(:book)
        create(:edition_with_new_copy, format: unmatched_format, book: b)
        e = create(:edition_with_new_copy, format: matched_format, book: b)
        c = e.new_copies.first
        c.stock = 0
        c.save
        subject.should be_empty
      end
    end

    describe "filter by category" do
      let(:params) {{ category: "3" }}
      let(:unmatched_category) { create(:book_type, id: 5) }
      let(:matched_category) { create(:book_type, id: 3) }
      
      it "is empty for a non-existant category" do
        create(:book_with_new_copy)
        subject.should be_empty
      end

      it "is empty with no matching books" do
        create(:book_with_used_copy, book_type: unmatched_category)
        subject.should be_empty
      end

      it "returns any matching books" do
        b1 = create(:book_with_used_copy, book_type: matched_category)
        b2 = create(:book_with_used_copy, book_type: unmatched_category)
        b3 = create(:book_with_new_copy, book_type: matched_category)
        subject.should =~ [b1,b3]
      end
    end

    describe "filter by age" do
      let(:params) {{ age: "8" }}

      it "does not return books without an age set" do
        create(:book_with_used_copy)
        subject.should be_empty
      end

      context "only age_from set" do
        it "returns books with a matching age_from" do
          b = create(:book_with_used_copy, age_from: 8)
          subject.should == [b]
        end

        it "does not return books with a higher age_from" do
          create(:book_with_used_copy, age_from: 9)
          subject.should be_empty
        end

        it "does not return books with a lower age_from" do
          create(:book_with_used_copy, age_from: 7)
          subject.should be_empty
        end        
      end

      context "only age_to set" do
        it "returns books with a matching age_to" do
          b = create(:book_with_used_copy, age_to: 8)
          subject.should == [b]
        end

        it "does not return books with a higher age_to" do
          create(:book_with_used_copy, age_to: 9)
          subject.should be_empty
        end

        it "does not return books with a lower age_to" do
          create(:book_with_used_copy, age_to: 7)
          subject.should be_empty
        end        
      end

      context "both age_from and age_to set" do
        it "does not return a book with a higher age_from" do
          create(:book_with_used_copy, age_from: 9, age_to: 11)
          subject.should be_empty
        end

        it "does not return a book with a lower age_to" do
          create(:book_with_used_copy, age_from: 5, age_to: 7)
          subject.should be_empty
        end

        it "returns a book where the age lies between age_from and age_to" do
          b = create(:book_with_used_copy, age_from: 7, age_to: 10)
          subject.should == [b]
        end

        it "returns a book with a matching age_from" do
          b = create(:book_with_used_copy, age_from: 8, age_to: 10)
          subject.should == [b]
        end

        it "returns a book with a matching age_to" do
          b = create(:book_with_used_copy, age_from: 7, age_to: 8)
          subject.should == [b]
        end
      end
    end

    describe "filter by price" do
      context "only price_to set" do
        let(:params) {{ price_to: "70" }}

        it "returns books with copy price is between 0 and price_to" do
          b1 = create(:book_with_used_copy, price: 0)
          b2 = create(:book_with_new_copy, price: 60)
          b3 = create(:book_with_used_copy, price: 70)
          b4 = create(:book_with_new_copy, price: 71)
          subject.should =~ [b1,b2,b3]
        end
      end

      context "only price_from set" do
        let(:params) {{ price_from: "50" }}

        it "returns books with a copy price >= price_from" do
          b1 = create(:book_with_used_copy, price: 0)
          b2 = create(:book_with_new_copy, price: 49)
          b3 = create(:book_with_used_copy, price: 50)
          b4 = create(:book_with_new_copy, price: 51)
          b5 = create(:book_with_used_copy, price: 1000)
          subject.should =~ [b3,b4,b5]
        end
      end

      context "both price_from and price_to set" do
        let(:params) {{ price_from: "40", price_to: "120" }}

        it "returns books between the range" do
          b1 = create(:book_with_used_copy, price: 0)
          b2 = create(:book_with_new_copy, price: 39)
          b3 = create(:book_with_used_copy, price: 40)
          b4 = create(:book_with_new_copy, price: 70)
          b5 = create(:book_with_used_copy, price: 120)
          b6 = create(:book_with_used_copy, price: 121)
          subject.should =~ [b3,b4,b5]
        end

        it "returns a book with only one copy matching" do
          b = create(:book_with_used_copy, price: 30)
          create(:edition_with_new_copy, book: b, price: 50)
          subject.should == [b]
        end

        it "does not return a book with an out of stock matching copy" do
          b = create(:book_with_used_copy, price: 30)
          e = create(:edition_with_new_copy, book: b, price: 50)
          c = e.new_copies.first
          c.stock = 0
          c.save
          subject.should be_empty
        end
      end

      context "price param set" do
        context "price below some val" do
          let(:params) {{ price: "-70" }}

          it "returns books with an equal or lower price" do
            b1 = create(:book_with_used_copy, price: 0)
            b2 = create(:book_with_new_copy, price: 60)
            b3 = create(:book_with_used_copy, price: 70)
            b4 = create(:book_with_new_copy, price: 71)
            subject.should =~ [b1,b2,b3]
          end
        end

        context "price above some val" do
          let(:params) {{ price: "50+" }}

          it "returns books with an equal or higher price" do
            b1 = create(:book_with_used_copy, price: 0)
            b2 = create(:book_with_new_copy, price: 49)
            b3 = create(:book_with_used_copy, price: 50)
            b4 = create(:book_with_new_copy, price: 51)
            b5 = create(:book_with_used_copy, price: 1000)
            subject.should =~ [b3,b4,b5]
          end
        end

        context "between two vals" do
          let(:params) {{ price: "40-120" }}

          it "returns books between the range" do
            b1 = create(:book_with_used_copy, price: 0)
            b2 = create(:book_with_new_copy, price: 39)
            b3 = create(:book_with_used_copy, price: 40)
            b4 = create(:book_with_new_copy, price: 70)
            b5 = create(:book_with_used_copy, price: 120)
            b6 = create(:book_with_used_copy, price: 121)
            subject.should =~ [b3,b4,b5]
          end

          it "returns a book with only one copy matching" do
            b = create(:book_with_used_copy, price: 30)
            create(:edition_with_new_copy, book: b, price: 50)
            subject.should == [b]
          end

          it "does not return a book with an out of stock matching copy" do
            b = create(:book_with_used_copy, price: 30)
            e = create(:edition_with_new_copy, book: b, price: 50)
            c = e.new_copies.first
            c.stock = 0
            c.save
            subject.should be_empty
          end
        end
      end
    end
  end
end