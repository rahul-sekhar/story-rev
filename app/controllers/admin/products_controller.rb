class Admin::ProductsController < Admin::ApplicationController
  def index
    @class = "product stock-taking"
    @title = "Stock Taking"
    
    @copies = Copy.stocked.includes({ :edition => :product }, :stock)
    
    respond_to do |format|
      format.html
      format.json { render :json => Product.includes_data.all.map{|x| x.get_list_hash} }
    end
  end
  
  def search
    @class = "product search"
    @title = "Search"
    
    respond_to do |format|
      format.html
      format.json { render :json => Product.search(params[:q], params[:search_by], params[:output]) }
    end
  end
  
  def show
    @class = "product editions"
    @title = "Copies & Editions"
    @product = Product.find(params[:id])    
  end
  
  def new
    @class = "product form"
    @title = "Add Product"
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
    @title = "Edit Book Information"
    @product = Product.find(params[:id])
    @product.build_empty_fields
  end
  
  def update
    @product = Product.find(params[:id])
    if @product.update_attributes(params[:product])
      redirect_to search_admin_products_path, :notice => "Product saved - its accession number is #{@product.accession_id}"
    else
      @product.build_empty_fields
      @class = "product form"
      render "edit"
    end
  end
  
  def destroy
    @product = Product.find(params[:id])
    @product.destroy
    redirect_to search_admin_products_path, :notice => "Product #{@product.accession_id} - #{@product.title} has been deleted"
  end
  
  def amazon_info
    @info_objects = AWSInfo.search(params[:title])
    
    respond_to do |format|
      format.json { render :json => @info_objects }
    end
  end
end
