class ShoppingCartsController < ApplicationController
  def update
    store_shopping_cart
    if shopping_cart.update_attributes(params[:shopping_cart])
      respond_to do |format|
        format.html { redirect_to shopping_cart_path }
        format.json {
          render :json => {
            :item_count => shopping_cart.items,
            :html => params[:get_html] ? render_to_string(:action => "index.html", :layout => "ajax") : nil
          }
        }
      end
    else
      respond_to do |format|
        format.html { redirect_to request.referer, :notice => "The shopping cart could not be updated." }
        format.json { render :json => { :success => false, :status => :unprocessable_entity }}
      end
    end
  end
  
  def index
    @class = "store shopping-cart"
    @title = "Shopping Cart"
    
    render :layout => "ajax" if (params[:ajax])
  end
end