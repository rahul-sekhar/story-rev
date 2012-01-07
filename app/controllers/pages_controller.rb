class PagesController < ApplicationController
  
  def store
    @products = Product.all
  end
end
