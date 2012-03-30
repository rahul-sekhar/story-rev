class Admin::OrdersController < Admin::ApplicationController
  def pending
    @title = "Pending Orders"
    @class = "orders pending"
    
    @orders = Order.where("step = 5 AND (confirmed = FALSE OR paid = FALSE OR packaged = FALSE OR posted = FALSE)")
  end
  
  def new
    @title = "Add Order"
    @class = "orders new"
    @order = Order.new(:step => 5)
  end
  
  def create
    @order = Order.new(params[:order])
    @order.step = 5
    @order.pickup_point_id ||= 0
    
    if @order.save
      redirect_to pending_admin_orders_path(:selected_order_id => @order.id), :notice => "Order created - it's order number is #{@order.id}"
    else
      @class = "orders new"
      @title = "Add Order"
      render "new"
    end
  end
  
  def edit
    @title = "Add Order"
    @class = "orders new"
    @order = Order.find(params[:id])
  end
  
  def update
    @order = Order.find(params[:id])
    @order.pickup_point_id ||= 0
    
    if params[:order][:add_copy].present?
      @order.add_copy(params[:order][:add_copy])
      params[:order].delete(:add_copy)
    end
    
    if @order.update_attributes(params[:order])
      respond_to do |f|
        f.html { redirect_to pending_admin_orders_path(:selected_order_id => @order.id), :notice => "Order saved - it's order number is #{@order.id}" }
        f.json { render :json => @order.amount_hash }
      end
    else
      respond_to do |f|
        f.html do
          @title = "Add Order"
          @class = "orders new"
          render "edit"
        end
        f.json { render :json => @order.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end
  
  def index
    @title = "Old Orders"
    @class = "orders old"
    
    @orders = Order.where("step = 5 AND confirmed = TRUE AND paid = TRUE AND packaged = TRUE AND posted = TRUE")
  end
  
  def show
    @order = Order.find(params[:id])
    
    if params[:amount].present?
      render :json => @order.amount_hash
    else
      render :json => @order.get_hash
    end
  end
  
  def destroy
    @order = Order.find(params[:id])
    @order.revert_copies
    @order.destroy
    render :json => { :success => true }
  end
end