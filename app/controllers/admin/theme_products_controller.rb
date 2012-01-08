class Admin::ThemeProductsController < Admin::ApplicationController
  respond_to :json
  
  def index
    @theme = Theme.find(params[:theme_id])
    render :json => @theme.products.map { |x| x.get_theme_hash }
  end
  
  def destroy
    @theme = Theme.find(params[:theme_id])
    @product = Product.find(params[:id])
    @theme.products.delete(@product)
    render :json => { :success => true }
  end
end
