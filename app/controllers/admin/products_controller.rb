class Admin::ProductsController < Admin::ApplicationController
  def index
    @class = "product search"
    respond_to do |format|
      format.html
      format.json do
        render :json => []
      end
    end
  end
  
  def new
    @class = "product form"
    @product = Product.new
    @product.build_empty_fields
  end
  
  def create
    @product = Product.new(params[:product])
    if @product.save
      redirect_to admin_products_path, :notice => "Product created"
    else
      flash.now.alert = "Some fields are not valid"
      render "new"
    end
  end
  
  def edit
    @class = "product form"
    @product = Product.find(params[:id])
    @product.build_empty_fields
  end
  
  def update
    @product = Product.find(params[:id])
    if @product.update_attributes(params[:product])
      redirect_to admin_products_path, :notice => "Product saved"
    else
      flash.now.alert = "Some fields are not valid"
      render "edit"
    end
  end
end
