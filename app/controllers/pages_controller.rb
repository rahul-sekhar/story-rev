class PagesController < ApplicationController
  
  def store
    @class = "store"
    @title = "Store"
    @products = Product.stocked.includes_cover.page(params[:page]).per(20)
    @themes = Theme.all
  end
  
  def more_info
    @section = params[:section]
    render :layout => "ajax"
  end
end
