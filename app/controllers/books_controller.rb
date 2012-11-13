class BooksController < ApplicationController
  def show
    @class = "store book"
    @book = Book.find_by_accession_id!(params[:id])
    @title = @book.title

    @new_copies = @book.new_copies.stocked.includes_edition
    @used_copies = @book.used_copies.stocked.includes_edition
  end
end
