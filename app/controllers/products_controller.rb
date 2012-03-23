class ProductsController < ApplicationController
  def show
    @class = "store product"
    @product = Product.find(params[:id])
    if (params[:ajax])
      render :layout => "ajax"
    end
  end
end
