class Admin::OrdersController < Admin::ApplicationController
  def pending
    @title = "Pending Orders"
    @class = "orders pending"
    
    @orders = CompleteOrder.includes{[order_copies, customer]}.unfinalized.order_by_confirmed
  end
  
  def index
    @title = "Old Orders"
    @class = "orders old"
    
    @orders = CompleteOrder.includes{[order_copies, customer]}.finalized.order_by_confirmed
  end
  
  def show
    @order = CompleteOrder.find(params[:id])
    
    render json: present(@order).as_hash
  end
  
  def update
    @order = CompleteOrder.find(params[:id])
    
    if @order.update_attributes(params[:order])
      render json: present(@order).as_hash
    else
      render json: @order.errors.full_messages, status: :unprocessable_entity
    end
  end
  
  def destroy
    @order = CompleteOrder.find(params[:id])
    @order.destroy
    render json: { success: true }
  end
end