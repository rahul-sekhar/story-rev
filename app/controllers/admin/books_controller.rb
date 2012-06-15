class Admin::BooksController < Admin::ApplicationController
  def index
    @class = "book stock-taking"
    @title = "Stock Taking"
    
    @copies = Copy.stocked.includes({ :edition => :book }, :stock)
    
    respond_to do |format|
      format.html
      format.json { render :json => Book.includes_data.all.map{|x| x.get_list_hash} }
    end
  end
  
  def search
    @class = "book search"
    @title = "Search"
    
    respond_to do |format|
      format.html
      format.json { render :json => Book.search(params[:q], params[:search_by], params[:output]) }
    end
  end
  
  def show
    @class = "book editions"
    @title = "Copies & Editions"
    @book = Book.find(params[:id])    
  end
  
  def new
    @class = "book form"
    @title = "Add Book"
    @book = Book.new
    @book.build_empty_fields
    @book.title = params[:title] if params[:title]
  end
  
  def create
    @book = Book.new(params[:book])
    if @book.save
      redirect_to admin_book_path(@book), :notice => "Book created - its accession number is #{@book.accession_id}"
    else
      @book.build_empty_fields
      @class = "book form"
      @title = "Add Book"
      render "new"
    end
  end
  
  def edit
    @class = "book form"
    @title = "Edit Book Information"
    @book = Book.find(params[:id])
    @book.build_empty_fields
  end
  
  def update
    @book = Book.find(params[:id])
    if @book.update_attributes(params[:book])
      case params[:commit]
      when "Next Book"
        redirect_path = edit_admin_book_path(@book.next_book)
      when "Previous Book"
        redirect_path = edit_admin_book_path(@book.previous_book)
      else
        redirect_path = search_admin_books_path
      end
      
      redirect_to redirect_path, :notice => "Book saved - its accession number is #{@book.accession_id}"
    else
      @book.build_empty_fields
      @class = "book form"
      @title = "Edit Book Information"
      render "edit"
    end
  end
  
  def destroy
    @book = Book.find(params[:id])
    @book.destroy
    redirect_to search_admin_books_path, :notice => "Book #{@book.accession_id} - #{@book.title} has been deleted"
  end
  
  def amazon_info
    @info_objects = AWSInfo.search(params[:title])
    
    respond_to do |format|
      format.json { render :json => @info_objects }
    end
  end
end
