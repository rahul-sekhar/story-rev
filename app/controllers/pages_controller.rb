class PagesController < ApplicationController
  
  def store
    @class = "store"
    @title = "Store"
    
    params[:sort] = "date" if !params[:sort]
    
    @products = Product.stocked.includes_cover.includes(:copies).joins('LEFT JOIN "authors" as auth ON auth.id = products.author_id').filter(params).sort_by_param(params[:sort]).page(params[:page]).per(20)
    
    if params[:ajax]
      params.delete(:ajax)
      render "ajax_store", :layout => "ajax"
    end
  end
  
  def more_info
    @section = params[:section]
    render :layout => "ajax"
  end
end
