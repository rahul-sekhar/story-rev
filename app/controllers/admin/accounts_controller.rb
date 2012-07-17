class Admin::AccountsController < Admin::ApplicationController
  before_filter :require_admin, :except => :index
  
  def index
    @accounts = Account.default_order
    respond_to do |f|
      f.json do
        @accounts = @accounts.name_like(params[:q]).limit(10) if params[:q]
        render :json => @accounts, :only => [:id, :name]
      end
    end
  end
  
  def new
    @title = "Add account"
    @class = "finances config"
    @item = Account.new
    render "admin/pages/name_form"
  end
  
  def create
    @item = Account.new(params[:account])
    if @item.save
      redirect_to admin_finances_config_path
    else
      @title = "Add account"
      @class = "finances config"
      render "admin/pages/name_form"
    end
  end
  
  def edit
    @title = "Edit account"
    @class = "finances config"
    @item = Account.find(params[:id])
    render "admin/pages/name_form"
  end
  
  def update
    @item = Account.find(params[:id])
    if @item.update_attributes(params[:account])
      redirect_to admin_finances_config_path
    else
      @title = "Edit account"
      @class = "finances config"
      render "admin/pages/name_form"
    end
  end
  
  def to_default
    config = ConfigData.access
    config.default_account = Account.find(params[:account_id])
    config.save
    redirect_to admin_finances_config_path
  end
  
  def to_cash
    config = ConfigData.access
    config.cash_account = Account.find(params[:account_id])
    config.save
    redirect_to admin_finances_config_path
  end
  
  def destroy
    @item = Account.find(params[:id])
    @item.destroy
    redirect_to admin_finances_config_path
  end
end
