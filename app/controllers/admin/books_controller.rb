class Admin::BooksController < Admin::ApplicationController
  def index
    @class = "book stock-taking"
    @title = "Stock Taking"
    
    @copies = Copy.stocked.includes{[edition.book, edition.format, stock_taking]}
  end
  
  def search
    @class = "book search"
    @title = "Search"
    
    respond_to do |format|
      format.html
      format.json do
        render :json => BookSearcher.search(params[:q]).formatted_results
      end
    end
  end
  
  def show
    @class = "book editions"
    @title = "Copies & Editions"
    @book = Book.find_by_accession_id!(params[:id])    
  end
  
  def new
    @class = "book form"
    @title = "Add Book"
    @book = Book.new(flash[:book_params])
    @book.valid? if flash[:book_params].present?
    @book.build_empty_fields
    @book.title = params[:title] if params[:title]
  end
  
  def create
    @book = Book.new(params[:book])
    if @book.save
      redirect_to admin_book_path(@book), :notice => "Book created - its accession number is #{@book.accession_id}"
    else
      flash[:book_params] = params[:book]
      redirect_to :action => :new
    end
  end
  
  def edit
    @class = "book form"
    @title = "Edit Book Information"
    @book = Book.find_by_accession_id!(params[:id])
    if flash[:book_params].present?
      @book.update_attributes(flash[:book_params])
      @book.valid?
    end
    @book.build_empty_fields
  end
  
  def update
    @book = Book.find_by_accession_id!(params[:id])
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
      flash[:book_params] = params[:book]
      redirect_to :action => :edit
    end
  end
  
  def destroy
    @book = Book.find_by_accession_id!(params[:id])
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
