class PagesController < ApplicationController
  include ApplicationHelper
  
  def store
    @class = "store"
    @title = "Store"
    
    check_params
    
    @products = Product.stocked.includes_cover.joins("LEFT JOIN authors AS auth ON products.author_id = auth.id").includes(:copies, :illustrator).filter(params).sort_by_param(params[:sort_by],params[:desc]).page(params[:page]).per(20)
    
    if params[:ajax].present?
      params.delete :ajax
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
    stocked_books = Product.unscoped.stocked
    stocked_book_ids = stocked_books.map{ |x| x.id }
    stocked_editions = Edition.unscoped.where( :product_id => stocked_book_ids )
    stocked_awards = Award.unscoped.where('awards.id IN (SELECT award_id FROM products_awards WHERE product_id IN (?))', stocked_book_ids)
    
    @product_types = ProductType.visible.prioritised.where(:id => stocked_books.map{ |x| x.product_type_id })
    @formats = Format.where(:id => stocked_editions.map{ |x| x.format_id})
    @collections = Collection.prioritised.visible.where('"collections"."id" IN (SELECT collection_id FROM products_collections WHERE product_id IN (?))', stocked_book_ids)
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
