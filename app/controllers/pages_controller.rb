class PagesController < ApplicationController
  include ApplicationHelper
  
  def store
    @class = "store main"
    @title = "Store"
    
    check_params
    set_seed
    @books = Book.filter(params)
      .sort(params[:sort_by],params[:desc])
      .page(params[:page]).per(20)

    # Eager loading causes a bug with sorting by price
    unless params[:sort_by] == "price"
      @books = @books.includes{[cover_image, used_copies, new_copies, illustrator]} 
    end

    # Show the shopping cart if necessary
    if params[:show_cart].present?
      params.delete :show_cart
      @show_shopping_cart = true
    end
    
    if request.xhr?
      render json: ajax_params
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
    @email = params[:email]
    email_subscription = EmailSubscription.new(email: @email)
    
    if email_subscription.save
      UpdateMailer.delay.subscribe_mail(@email)
      UpdateMailer.delay.notify_owner(@email)

      respond_to do |f|
        f.html do 
          flash[:subscribed] = true
          redirect_to root_path(anchor: 'page-footer')
        end
        f.json { render json: { success: true }}
      end

    else
      respond_to do |f|
        f.html do 
          flash[:subscription_error] = email_subscription.error_message
          redirect_to root_path(anchor: 'page-footer')
        end
        f.json { render json: { error: email_subscription.error_message }}
      end  
    end
  end
  
  private
  
  def check_params
    # Check the price params
    params.delete(:price) if params[:price_to].present? || params[:price_from].present?
    
    # Set the default sort parameter
    params[:sort_by] = "random" unless params[:sort_by].present?
  end

  def set_seed
    if params[:sort_by] == "random"
      seed = params[:seed].to_s
      if seed.match(/\A\d+\z/) && seed.to_i > 0 && seed.to_i < 9999
        seed = seed.to_i
      else
        seed = rand(1..9999)
      end
      params[:seed] = seed.to_s
      Book.connection.execute("select setseed(#{seed.to_f / 10000})")
    else
      params.delete(:seed)
    end
  end
  
  def get_collection_lists
    @book_types = BookType.joins{books}.visible.prioritised.where{books.in_stock == true}.group(BookType.columns_list)
    @formats = Format.joins{editions.copies}.where{editions.copies.stock > 0}.group(Format.columns_list)
    @collections = Collection.prioritised.visible.joins{books}.where{books.in_stock == true}.group(Collection.columns_list)
  end
  
  def ajax_params
    {
      :html => render_to_string(:action => "ajax_store", :layout => "ajax"),
      :sort_by => params[:sort_by],
      :desc => params[:desc],
      :base => get_base,
      :seed => params[:seed],
      :base_val => params[get_base],
      :filters => filter_list
    }
  end
end
