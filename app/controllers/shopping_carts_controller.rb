class ShoppingCartsController < ApplicationController
  def update
    store_shopping_cart
    if shopping_cart.update_attributes(params[:shopping_cart])
      respond_to do |format|
        format.html { redirect_to shopping_cart_path }
        format.json {
          
          @cart_copies = shopping_cart.shopping_cart_copies
          @cart_copies = @cart_copies.includes(:copy => {:edition => {:product => [:illustrator, :cover_image]}})
          @cart_copies = @cart_copies.order('"copies"."in_stock"')
          
          render :json => {
            :item_count => shopping_cart.items,
            :total => shopping_cart.total,
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
    
    @cart_copies = shopping_cart.shopping_cart_copies
    @cart_copies = @cart_copies.includes(:copy => {:edition => {:product => [:illustrator, :cover_image]}})
    @cart_copies = @cart_copies.order('"copies"."in_stock"')
    
    # Log if there are unavailable copies
    log_unavailable if (@cart_copies.unstocked.length > 0)
    
    if (params[:count])
      render :json => { :item_count => shopping_cart.items }
    else
      render :layout => "ajax" if (params[:ajax])
    end
  end
  
  
  def log_unavailable  
    msg = "Shopping cart ##{shopping_cart.id} viewed with:\n"
    msg += "#{@cart_copies.unstocked.length} unavailable copies\n"
    msg += "IDs - #{@cart_copies.unstocked.map{|x| x.copy_id}.join(", ")}"
    
    Loggers.store_log msg
  end
end