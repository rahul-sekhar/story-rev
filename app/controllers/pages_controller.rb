class PagesController < ApplicationController
  
  def store
    @products = Product.stocked
  end
end
