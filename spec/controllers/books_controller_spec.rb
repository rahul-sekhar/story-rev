require "spec_helper"

describe BooksController do
  describe "GET show" do
    context "valid id" do
      before do
        @book = mock_model(Book)
        @book.stub(:title).and_return("Test Title")
        Book.should_receive(:find_by_accession_id!).with("12").and_return(@book)
        get :show, id: 12
      end

      it "has a 200 status code" do
        response.code.should eq("200")
      end

      it "assigns the correct book" do
        assigns(:book).should eq(@book)
      end

      it "sets the page title" do
        assigns(:title).should eq("Test Title")
      end
    end

    context "invalid id" do
      it "is 404" do
        expect do
          get :show, id: 55
        end.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end
  end
end