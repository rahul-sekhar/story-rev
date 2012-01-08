class Admin::ThemesController < Admin::ApplicationController
  respond_to :json
  
  def index
    @class = "themes"
    @themes = Theme.includes(:theme_icon).all
  end
  
  def create
    @theme = Theme.new(params[:theme])
    if @theme.save
      render :json => @theme.get_hash
    else
      render :json => @theme.errors.full_messages, :status => :unprocessable_entity
    end
  end
  
  def update
    @theme = Theme.find(params[:id])
    if @theme.update_attributes(params[:theme])
      render :json => @theme.get_hash
    else
      render :json => @theme.errors.full_messages, :status => :unprocessable_entity
    end
  end
  
  def destroy
    @theme = Theme.find(params[:id])
    @theme.destroy
    render :json => { :success => true }
  end
  
  def show
    @theme = Theme.find(params[:id])
    @products = Product.all
  end
  
  def update_products
    @theme = Theme.find(params[:theme_id])
    @theme.product_ids = params[:products]
    redirect_to admin_themes_path, :notice => "The product list for '#{@theme.name}' has been updated"
  end
  
end
