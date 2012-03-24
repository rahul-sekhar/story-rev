class ProductsController < ApplicationController
  def show
    @class = "store product"
    @product = Product.find(params[:id])
    @title = @product.title
  end
end
