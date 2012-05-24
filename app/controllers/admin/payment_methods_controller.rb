class Admin::PaymentMethodsController < Admin::ApplicationController
  before_filter :require_admin, :except => :index
  
  def index
    @payment_methods = PaymentMethod.scoped
    respond_to do |f|
      f.json do
        @payment_methods = @payment_methods.name_like(params[:q]).limit(10) if params[:q]
        render :json => @payment_methods, :only => [:id, :name]
      end
    end
  end
  
  def new
    @title = "Add payment method"
    @class = "finances config"
    @item = PaymentMethod.new
    render "admin/pages/name_form"
  end
  
  def create
    @item = PaymentMethod.new(params[:payment_method])
    if @item.save
      redirect_to admin_finances_config_path
    else
      @title = "Add payment method"
      @class = "finances config"
      render "admin/pages/name_form"
    end
  end
  
  def edit
    @title = "Edit payment method"
    @class = "finances config"
    @item = PaymentMethod.find(params[:id])
    render "admin/pages/name_form"
  end
  
  def update
    @item = PaymentMethod.find(params[:id])
    if @item.update_attributes(params[:payment_method])
      redirect_to admin_finances_config_path
    else
      @title = "Edit payment method"
      @class = "finances config"
      render "admin/pages/name_form"
    end
  end
  
  def destroy
    @item = PaymentMethod.find(params[:id])
    @item.destroy
    redirect_to admin_finances_config_path
  end
end
