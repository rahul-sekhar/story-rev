class Admin::CollectionBooksController < Admin::ApplicationController
  respond_to :json
  
  def index
    @collection = Collection.find(params[:collection_id])
    if params[:all_books].present?
      collection_book_ids = @collection.book_ids
      books = Book.includes{[used_copies, new_copies, collections, book_awards, illustrator]}.all
      render :json => books.map {|x| present(x).as_list_hash.merge({in_collection: collection_book_ids.include?(x.id) }) }
    else
      render :json => @collection.books.includes{[new_copies, used_copies]}.map { |x| present(x).as_collection_hash }
    end
  end
  
  def create
    @collection = Collection.find(params[:collection_id])
    @book = Book.find(params[:book_id])
    @collection.books << @book unless @book.in_collection?(@collection)
    if @collection.save
      render :json => { :success => true, :in_collection => @book.in_collection?(@collection) }
    else
      format.json { render :status => :unprocessable_entity }
    end
  end
  
  def destroy
    @collection = Collection.find(params[:collection_id])
    @book = Book.find(params[:id])
    @collection.books.delete(@book)
    render :json => { :success => true, :in_collection => @book.in_collection?(@collection) }
  end
end
