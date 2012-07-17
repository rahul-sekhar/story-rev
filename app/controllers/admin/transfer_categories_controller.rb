class Admin::TransferCategoriesController < Admin::ApplicationController
  before_filter :require_admin, :except => :index
  
  def index
    @categories = TransferCategory.scoped
    respond_to do |f|
      f.json do
        @categories = @categories.name_like(params[:q]).limit(10) if params[:q]
        render :json => @categories, :only => [:id, :name]
      end
    end
  end
  
  def new
    @title = "Add transfer category"
    @class = "finances config"
    @item = TransferCategory.new
    render "admin/pages/name_form"
  end
  
  def create
    @item = TransferCategory.new(params[:transfer_category])
    if @item.save
      redirect_to admin_finances_config_path
    else
      @title = "Add transfer category"
      @class = "finances config"
      render "admin/pages/name_form"
    end
  end
  
  def edit
    @title = "Edit transfer category"
    @class = "finances config"
    @item = TransferCategory.find(params[:id])
    render "admin/pages/name_form"
  end
  
  def update
    @item = TransferCategory.find(params[:id])
    if @item.update_attributes(params[:transfer_category])
      redirect_to admin_finances_config_path
    else
      @title = "Edit transfer category"
      @class = "finances config"
      render "admin/pages/name_form"
    end
  end
  
  def destroy
    @item = TransferCategory.find(params[:id])
    @item.destroy
    redirect_to admin_finances_config_path
  end
end
