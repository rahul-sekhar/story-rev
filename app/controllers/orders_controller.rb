class OrdersController < ApplicationController
  before_filter :check_shopping_cart
  skip_before_filter :check_shopping_cart, :only => :destroy
  
  def new
    @class= "store order"
    @title = "Order"
    @order = (shopping_cart.order || shopping_cart.build_order)
    
    @order.calculate_total if @order.step == 4
    
    render :layout => "ajax" if request.xhr?
  end
  
  def create
    @class = "store order"
    @title = "Order"
    
    if shopping_cart.order
      @order = shopping_cart.order
      @order.update_attributes(params[:order])
    else
      @order = shopping_cart.build_order(params[:order])
      @order.save
    end
    
    if (@order.complete?)
      @order.finalise
      OrderMailer.delay.confirmation(@order)
      OrderMailer.delay.notify_owner(@order)
      render "confirmation", :layout => request.xhr? ? "ajax" : true
    else
      render "new", :layout => request.xhr? ? "ajax" : true
    end
  end
  
  def destroy
    shopping_cart.order && shopping_cart.order.destroy
    if request.xhr?
      render :json => { :success => true }
    else
      redirect_to root_path( show_cart: true)
    end
  end
  
  def check_shopping_cart
    if shopping_cart.shopping_cart_copies.stocked.length == 0
      if shopping_cart.items > 0
        message = "We're very sorry, but someone else has ordered the item(s) in your shopping cart, and they are now unavailable."
      else
        message = "Your shopping cart is empty, so an order cannot be placed."
      end
      
      if request.xhr?
        render :text => message, :status => 400
      else
        redirect_to shopping_cart_url, :notice => message
      end
    end
  end
end
