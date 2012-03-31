class PagesController < ApplicationController
  
  def store
    @class = "store"
    @title = "Store"
    
    params[:sort] = "date" if !params[:sort]
    
    @products = Product.stocked.includes_cover.includes(:copies).filter(params)
    
    @products = @products.sort_by_param(params[:sort])
    
    @products = @products.page(params[:page]).per(20)
    
    @themes = Theme.all
  end
  
  def more_info
    @section = params[:section]
    render :layout => "ajax"
  end
end
