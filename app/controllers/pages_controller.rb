class PagesController < ApplicationController
  
  def store
    @class = "store"
    @title = "Store"
    
    unless params[:condition]
      params[:condition] = {}
      (1..5).each { |i| params[:condition][i.to_s] = 1 }
    end
    
    @products = Product.stocked.includes_cover.filter(params).page(params[:page]).per(20)
    
    @themes = Theme.all
  end
  
  def more_info
    @section = params[:section]
    render :layout => "ajax"
  end
end
