class OrdersController < ApplicationController
  before_filter :check_shopping_cart
  skip_before_filter :check_shopping_cart, :only => :destroy
  
  def new
    @class= "store order"
    @order = (shopping_cart.order || shopping_cart.build_order)
    
    render :layout => "ajax" if params[:ajax]
  end
  
  def create
    @class= "store order"
    
    if shopping_cart.order
      @order = shopping_cart.order
      @order.update_attributes(params[:order])
    else
      @order = shopping_cart.build_order(params[:order])
      @order.save
    end
    
    render "new", :layout => params[:ajax] ? "ajax" : true
  end
  
  def destroy
    shopping_cart.order && shopping_cart.order.destroy
    if params[:ajax]
      render :json => { :success => true }
    else
      redirect_to shopping_cart_path(:ajax => params[:ajax])
    end
  end
  
  def check_shopping_cart
    if shopping_cart.items == 0
      message = "Your shopping cart is empty, so an order cannot be placed."
      if params[:ajax]
        render :text => message, :status => 400
      else
        redirect_to shopping_cart_url, :notice => message
      end
    end
  end
end
