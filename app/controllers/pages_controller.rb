class PagesController < ApplicationController
  
  def store
    @class = "store"
    @products = Product.stocked.includes_cover.page(params[:page]).per(20)
  end
end
