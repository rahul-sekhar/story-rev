class Admin::CollectionBooksController < Admin::ApplicationController
  respond_to :json
  
  def index
    @collection = Collection.find(params[:collection_id])
    if params[:all_books].present?
      collection_book_ids = @collection.book_ids
      render :json => Book.includes_data.includes_copies.all.map {|x| x.get_list_hash.merge ({ :in_collection => collection_book_ids.include?(x.id) }) }
    else
      render :json => @collection.books.includes_copies.map { |x| x.get_collection_hash }
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