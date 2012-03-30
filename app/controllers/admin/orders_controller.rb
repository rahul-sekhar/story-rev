class Admin::OrdersController < Admin::ApplicationController
  def pending
    @title = "Pending Orders"
    @class = "orders pending"
    
    @orders = Order.where("step = 5 AND (confirmed = FALSE OR paid = FALSE OR packaged = FALSE OR posted = FALSE)")
  end
  
  def update
    @order = Order.find(params[:id])
    if @order.update_attributes(params[:order])
      render :json => { :success => true, :params => params.inspect }
    else
      render :json => @order.errors.full_messages, :status => :unprocessable_entity
    end
  end
  
  def show
    @order = Order.find(params[:id])
    render :json => @order.get_hash
  end
end