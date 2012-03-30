class Admin::OrdersController < Admin::ApplicationController
  def pending
    @title = "Pending Orders"
    @class = "orders pending"
    
    @orders = Order.where("step = 5 AND (confirmed = FALSE OR paid = FALSE OR packaged = FALSE OR posted = FALSE)")
  end
  
  def update
    @order = Order.find(params[:id])
    
    if params[:order][:add_copy].present?
      @order.add_copy(params[:order][:add_copy])
      params[:order].delete(:add_copy)
    end
    
    if @order.update_attributes(params[:order])
      render :json => { :success => true }
    else
      render :json => @order.errors.full_messages, :status => :unprocessable_entity
    end
  end
  
  def index
    @title = "Old Orders"
    @class = "orders old"
    
    @orders = Order.where("step = 5 AND confirmed = TRUE AND paid = TRUE AND packaged = TRUE AND posted = TRUE")
  end
  
  def show
    @order = Order.find(params[:id])
    render :json => @order.get_hash
  end
  
  def destroy
    @order = Order.find(params[:id])
    @order.revert_copies
    @order.destroy
    render :json => { :success => true }
  end
end