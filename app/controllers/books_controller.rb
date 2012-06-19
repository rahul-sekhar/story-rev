class BooksController < ApplicationController
  def show
    @class = "store book"
    @book = BookDecorator.find(params[:id])
    @title = @book.title
  end
end
