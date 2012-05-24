class Admin::TransactionCategoriesController < Admin::ApplicationController
  before_filter :require_admin, :except => :index
  
  def index
    @categories = TransactionCategory.scoped
    respond_to do |f|
      f.json do
        @categories = @categories.name_like(params[:q]).limit(10) if params[:q]
        render :json => @categories, :only => [:id, :name, :off_record]
      end
    end
  end
  
  def new
    @title = "Add transaction category"
    @class = "finances config"
    @item = TransactionCategory.new
    render "admin/pages/name_form"
  end
  
  def create
    @item = TransactionCategory.new(params[:transaction_category])
    if @item.save
      redirect_to admin_finances_config_path
    else
      @title = "Add transaction category"
      @class = "finances config"
      render "admin/pages/name_form"
    end
  end
  
  def edit
    @title = "Edit transaction category"
    @class = "finances config"
    @item = TransactionCategory.find(params[:id])
    render "admin/pages/name_form"
  end
  
  def update
    @item = TransactionCategory.find(params[:id])
    if @item.update_attributes(params[:transaction_category])
      redirect_to admin_finances_config_path
    else
      @title = "Edit transaction category"
      @class = "finances config"
      render "admin/pages/name_form"
    end
  end
  
  def toggle_record
    @item = TransactionCategory.find(params[:transaction_category_id])
    @item.toggle_record
    @item.save
    redirect_to admin_finances_config_path
  end
  
  def destroy
    @item = TransactionCategory.find(params[:id])
    @item.destroy
    redirect_to admin_finances_config_path
  end
end
