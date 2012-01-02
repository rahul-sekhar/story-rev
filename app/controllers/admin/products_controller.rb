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
      redirect_to admin_products_path, :notice => "Product created - its accession number is #{@product.accession_id}"
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
      redirect_to admin_products_path, :notice => "Product saved - its accession number is #{@product.accession_id}"
    else
      flash.now.alert = "Some fields are not valid"
      render "edit"
    end
  end
end
