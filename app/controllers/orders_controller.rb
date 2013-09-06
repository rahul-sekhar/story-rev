class OrdersController < ApplicationController

  before_filter :check_order, only: [:show_step, :submit_step, :confirmation]

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

    # Skip updating the order since the store is closed
    respond_to do |format|
      format.html { redirect_to shopping_cart_path }
      format.json { redirect_to action: :view_cart, get_html: params[:get_html], format: :json }
    end
    return

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
    # Show shopping cart since the store is closed
    redirect_to shopping_cart_path
    return

    return unless get_customer_and_set_step
    @customer.set_defaults

    # Calculate the order amounts and check unstocked copies if we're on the final step
    if @step == 4
      order.check_unstocked
      order.calculate_amounts
    end

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

  def confirmation
    @confirmed_order = order
    session.delete(:order_id)
    @confirmed_order.finalize

    OrderMailer.delay.confirmation(@confirmed_order)
    OrderMailer.delay.notify_owner(@confirmed_order)

    render layout: "ajax" if request.xhr?
  end

  def cancel_order
    order.customer.destroy if order.customer.present?
    if request.xhr?
      render json: { success: true }
    else
      redirect_to root_path(show_cart: true)
    end
  end

  private

  def check_order
    if order.order_copies.stocked.length == 0
      num = order.number_of_items
      if num > 0
        message = "We're very sorry, but someone else has ordered the #{num > 1 ? 'items' : 'item'} in your shopping cart, and #{num > 1 ? 'they are' : 'it is'} now unavailable."
      else
        message = "Your shopping cart is empty, so an order cannot be placed."
      end

      if request.xhr?
        render :text => message, :status => 400
      else
        redirect_to shopping_cart_path, :notice => message
      end
    end
  end

  def get_customer_and_set_step
    @step = params[:step].to_i
    @customer = order.customer || order.build_customer
    @customer.step = @step

    # If the step was invalid redirect to the last valid step
    if @customer.step == @step
      return true
    else
      redirect_to order_step_path(step: @customer.step)
      return false
    end
  end
end
