class BooksController < ApplicationController
  def show
    @class = "store book"
    @book = Book.find_by_accession_id!(params[:id])
    @title = @book.title
  end
end
