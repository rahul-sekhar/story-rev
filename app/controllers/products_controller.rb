class ProductsController < ApplicationController
  def show
    @class = "store product"
    @product = Product.find(params[:id])
    @title = @product.title
    
    render :layout => "ajax" if (params[:ajax])
  end
end
