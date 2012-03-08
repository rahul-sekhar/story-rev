class Admin::ProductsController < Admin::ApplicationController
  def index
    @class = "product search"
    respond_to do |format|
      format.html
      format.json do
        if params[:q].present?
          render :json => Product.search(params[:q], params[:search_by], params[:output])
        else
          head :ok
        end
      end
    end
  end
  
  def show
    @class = "product editions"
    @product = Product.find(params[:id])    
  end
  
  def new
    @class = "product form"
    @product = Product.new
    @product.build_empty_fields
    @product.title = params[:title] if params[:title]
  end
  
  def create
    @product = Product.new(params[:product])
    if @product.save
      redirect_to admin_product_path(@product), :notice => "Product created - its accession number is #{@product.accession_id}"
    else
      @product.build_empty_fields
      @class = "product form"
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
      redirect_to admin_products_path, :notice => "Product saved - its accession number is #{@product.accession_id}"
    else
      @product.build_empty_fields
      @class = "product form"
      render "edit"
    end
  end
  
  def destroy
    @product = Product.find(params[:id])
    @product.destroy
    redirect_to admin_products_path, :notice => "Product #{@product.accession_id} - #{@product.title} has been deleted"
  end
  
  def amazon_info
    @info_objects = AWSInfo.search(params[:title])
    
    respond_to do |format|
      format.json { render :json => @info_objects }
    end
  end
end
