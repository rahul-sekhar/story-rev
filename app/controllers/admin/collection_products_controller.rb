class Admin::CollectionProductsController < Admin::ApplicationController
  respond_to :json
  
  def index
    @collection = Collection.find(params[:collection_id])
    if params[:all_products].present?
      collection_product_ids = @collection.product_ids
      render :json => Product.includes_data.all.map {|x| x.get_list_hash.merge ({ :in_collection => collection_product_ids.include?(x.id) }) }
    else
      render :json => @collection.products.includes_copies.map { |x| x.get_collection_hash }
    end
  end
  
  def create
    @collection = Collection.find(params[:collection_id])
    @product = Product.find(params[:product_id])
    @collection.products << @product unless @product.in_collection?(@collection)
    if @collection.save
      render :json => { :success => true, :in_collection => @product.in_collection?(@collection) }
    else
      format.json { render :status => :unprocessable_entity }
    end
  end
  
  def destroy
    @collection = Collection.find(params[:collection_id])
    @product = Product.find(params[:id])
    @collection.products.delete(@product)
    render :json => { :success => true, :in_collection => @product.in_collection?(@collection) }
  end
end
