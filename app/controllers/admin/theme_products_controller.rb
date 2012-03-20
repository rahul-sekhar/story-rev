class Admin::ThemeProductsController < Admin::ApplicationController
  respond_to :json
  
  def index
    @theme = Theme.find(params[:theme_id])
    if params[:all_products].present?
      theme_product_ids = @theme.product_ids
      render :json => Product.includes_data.all.map {|x| x.get_list_hash.merge ({ :in_theme => theme_product_ids.include?(x.id) }) }
    else
      render :json => @theme.products.includes_copies.map { |x| x.get_theme_hash }
    end
  end
  
  def create
    @theme = Theme.find(params[:theme_id])
    @product = Product.find(params[:product_id])
    @theme.products << @product unless @product.in_theme?(@theme)
    if @theme.save
      render :json => { :success => true, :in_theme => @product.in_theme?(@theme) }
    else
      format.json { render :status => :unprocessable_entity }
    end
  end
  
  def destroy
    @theme = Theme.find(params[:theme_id])
    @product = Product.find(params[:id])
    @theme.products.delete(@product)
    render :json => { :success => true, :in_theme => @product.in_theme?(@theme) }
  end
end
