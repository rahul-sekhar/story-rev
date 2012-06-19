class PagesController < ApplicationController
  include ApplicationHelper
  
  def store
    @class = "store"
    @title = "Store"
    
    check_params
    
    @books = Book.stocked.includes(:cover_image, :copies, :illustrator)
    @books = @books.joins("LEFT JOIN authors AS auth ON books.author_id = auth.id")
    @books = @books.filter(params).sort_by_param(params[:sort_by],params[:desc]).page(params[:page]).per(20)
    @books = BookDecorator.decorate(@books)
    
    if request.xhr?
      render :json => ajax_params
    else
      get_collection_lists
    end
  end
  
  def about
    @title = "About"
    @class = "about"
  end
  
  def help
    @title = "Help"
    @class = "help"
  end
  
  def subscribe
    if params[:email].present?
      @email = params[:email]
      EmailSubscription.create(:email => @email)
      UpdateMailer.delay.subscribe_mail(@email)
      UpdateMailer.delay.notify_owner(@email)
    end
    
    respond_to do |f|
      f.html { redirect_to root_path(:subscribed => true, :anchor => "footer") }
      f.json { render :json => { :success => true }}
    end
  end
  
  private
  
  def check_params
    # Check the price params
    params.delete(:price) if params[:price_to].present? || params[:price_from].present?
    
    # Set the default sort parameter
    params[:sort_by] = "random" unless params[:sort_by].present?
  end
  
  def get_collection_lists
    stocked_books = Book.unscoped.stocked
    stocked_book_ids = stocked_books.map{ |x| x.id }
    stocked_editions = Edition.unscoped.where( :book_id => stocked_book_ids )
    stocked_awards = Award.unscoped.where('awards.id IN (SELECT award_id FROM books_awards WHERE book_id IN (?))', stocked_book_ids)
    
    @book_types = BookType.visible.prioritised.where(:id => stocked_books.map{ |x| x.book_type_id })
    @formats = Format.where(:id => stocked_editions.map{ |x| x.format_id})
    @collections = Collection.prioritised.visible.where('"collections"."id" IN (SELECT collection_id FROM books_collections WHERE book_id IN (?))', stocked_book_ids)
  end
  
  def ajax_params
    {
      :html => render_to_string(:action => "ajax_store", :layout => "ajax"),
      :sort_by => params[:sort_by],
      :desc => params[:desc],
      :base => get_base,
      :base_val => params[get_base],
      :filters => filter_list
    }
  end
end
