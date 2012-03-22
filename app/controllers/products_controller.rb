class ProductsController < ApplicationController
  def show
    @class = "store product"
    @product = Product.find(params[:id])
  end
end
