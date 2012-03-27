class ShoppingCartsController < ApplicationController
  def update
    store_shopping_cart
    if shopping_cart.update_attributes(params[:shopping_cart])
      respond_to do |format|
        format.html { redirect_to shopping_cart_path }
        format.json {
          @copies = shopping_cart.copies.includes(:edition => {:product => [:illustrator, :cover_image]})
          render :json => {
            :item_count => shopping_cart.items,
            :html => params[:get_html] ? render_to_string(:action => "index.html", :layout => "ajax") : nil
          }
        }
      end
    else
      message = "An internal problem occured. Please contact us if it persists."
      respond_to do |format|
        format.html { redirect_to request.referer, :alert => 500 }
        format.json { render :text => message, :status => status }
      end
    end
  end
  
  def index
    @class = "store shopping-cart"
    @title = "Shopping Cart"
    @copies = shopping_cart.copies.includes(:edition => {:product => [:illustrator, :cover_image]})
    
    # Log if there are unavailable copies
    if @copies.unstocked.length > 0
      Loggers.store_log "Shopping cart ##{shopping_cart.id} viewed with #{@copies.unstocked.length} unavailable copies with ids - #{@copies.unstocked.map{|x| x.id}.join(", ")}"
    end
    
    if (params[:count])
      render :json => { :item_count => shopping_cart.items }
    else
      render :layout => "ajax" if (params[:ajax])
    end
  end
end