class PagesController < ApplicationController
  
  def store
    @products = Product.in_stock
  end
end
