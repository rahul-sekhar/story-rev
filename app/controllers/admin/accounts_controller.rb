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
    @account = Account.new
  end
  
  def create
    @account = Account.new(params[:account])
    if @account.save
      redirect_to admin_finances_config_path
    else
      @title = "Add account"
      @class = "finances config"
      render "new"
    end
  end
  
  def edit
    @title = "Edit account"
    @class = "finances config"
    @account = Account.find(params[:id])
    render "new"
  end
  
  def update
    @account = Account.find(params[:id])
    if @account.update_attributes(params[:account])
      redirect_to admin_finances_config_path
    else
      @title = "Edit account"
      @class = "finances config"
      render "new"
    end
  end
  
  def destroy
    @account = Account.find(params[:id])
    @account.destroy
    redirect_to admin_finances_config_path
  end
end
