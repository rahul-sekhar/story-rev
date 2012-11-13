class Admin::OrderCopiesController < Admin::ApplicationController
  def index
    @order_copies = OrderCopy.finalized.where(order_id: params[:order_id]).includes{[copy.edition.book, copy.edition.format]}
    
    render :json => @order_copies.map {|x| present(x).as_hash}
  end
  
  def update
    @order_copy = OrderCopy.find(params[:id])
    if @order_copy.update_attributes(params[:order_copy])
      render json: present(@order_copy.complete_order).as_hash
    else
      render json: @order_copy.errors.full_messages, status: :unprocessable_entity
    end
  end
  
  def destroy
    @order_copy = OrderCopy.find(params[:id])
    @order_copy.destroy
    render json: present(@order_copy.complete_order).as_hash
  end
end