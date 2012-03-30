class Admin::OrderCopiesController < Admin::ApplicationController
  def index
    @order_copies = Order.find(params[:order_id]).order_copies  
    
    render :json => @order_copies.map {|x| x.get_hash}
  end
  
  def update
    @order_copy =  OrderCopy.find(params[:id])
    if @order_copy.update_attributes(params[:order_copy])
      @order_copy.order.calculate_total
      @order_copy.order.save
      render :json => { :success => true }
    else
      render :json => @order_copy.errors.full_messages, :status => :unprocessable_entity
    end
  end
  
  def destroy
    @order_copy =  OrderCopy.find(params[:id])
    @order_copy.revert_copy
    @order_copy.order.calculate_total
    @order_copy.order.save
    @order_copy.destroy
    
    render :json => { :success => true }
  end
end