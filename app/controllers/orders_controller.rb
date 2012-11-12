class OrdersController < ApplicationController
  
  def view_cart
    @class = "store shopping-cart"
    @title = "Shopping Cart"

    @order_copies = order.order_copies.order{[(copy.stock < 1), updated_at.desc]}
    
    respond_to do |format|
      format.html { render layout: "ajax" if request.xhr? }
      format.json do
       render json: {
          item_count: order.number_of_items,
          total: order.cart_amount,
          html: params[:get_html] ? render_to_string(formats: :html, layout: "ajax") : nil
        }
      end
    end
  end

  def update_cart
    store_order if order.new_record?
    
    if order.update_attributes(params[:order])
      respond_to do |format|
        format.html { redirect_to shopping_cart_path }
        format.json { redirect_to action: :view_cart, get_html: params[:get_html], format: :json }
      end
    else
      raise "Shopping cart update failed"
    end
  end

  def show_step
    return unless get_customer_and_set_step
    @customer.set_defaults
    
    render layout: "ajax" if request.xhr?
  end

  def submit_step
    return unless get_customer_and_set_step
    
    if @customer.update_attributes(params[:customer])
      redirect_to order_step_path(step: @step + 1)
    else
      render "show_step", layout: request.xhr? ? "ajax" : true
    end
  end

  def cancel_order
    order.customer.destroy if order.customer.present?
    if request.xhr?
      render json: { success: true }
    else
      redirect_to root_path(show_cart: true)
    end
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

  private

  def get_customer_and_set_step
    @step = params[:step].to_i
    @customer = order.customer || order.build_customer
    @customer.step = @step

    # If the step was invalid redirect to the last valid step
    if @customer.step == @step
      # Calculate the order amounts if we're on the final step
      order.calculate_amounts if @step == 4
      return true
    else
      redirect_to order_step_path(step: @customer.step)
      return false
    end
  end
end
