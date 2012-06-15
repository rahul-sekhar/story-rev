class BooksController < ApplicationController
  def show
    @class = "store book"
    @book = Book.find(params[:id])
    @title = @book.title
  end
end
