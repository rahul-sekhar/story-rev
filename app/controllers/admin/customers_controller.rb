class Admin::CustomersController < Admin::ApplicationController
  def new
    @title = "Add Order"
    @class = "orders new"
    @customer = Customer.new
    @customer.delivery_method = 1
    @customer.payment_method_id = 1
  end
  
  def create
    @customer = Customer.new(params[:customer])
    @customer.pickup_point_id ||= 0
    @customer.step = 4
    
    if @customer.valid?
      order = CompleteOrder.create
      @customer.complete_order = order
      @customer.save
      order = present(order)
      redirect_to order.get_url, notice: "Order created - it's order number is #{order.number}"
    else
      @class = "orders new"
      @title = "Add Order"
      render "new"
    end
  end
  
  def edit
    @title = "Add Order"
    @class = "orders new"
    @customer = Customer.find(params[:id])
  end

  def update
    @customer = Customer.find(params[:id])
    @customer.pickup_point_id ||= 0
    @customer.step = 4
    
    if @customer.update_attributes(params[:customer])

      order = present(@customer.complete_order)
      redirect_to order.get_url, notice: "Order ##{order.number} saved"
    else
      @class = "orders new"
      @title = "Add Order"
      render "new"
    end
  end
end