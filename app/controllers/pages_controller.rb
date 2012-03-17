class PagesController < ApplicationController
  
  def store
    @class = "store"
    @products = Product.stocked.page(params[:page]).per(20)
  end
end
