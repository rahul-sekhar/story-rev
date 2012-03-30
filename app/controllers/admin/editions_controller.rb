class Admin::EditionsController < Admin::ApplicationController
  
  def index
    @editions = Product.find(params[:product_id]).editions
    
    respond_to do |format|
      format.json { render :json => @editions.map { |x| x.get_hash }}
    end
  end
  
  def create
    @product = Product.find(params[:product_id])
    @edition = @product.editions.build(params[:edition])
    respond_to do |format|
      if @edition.save
        format.json { render :json => @edition.get_hash }
      else
        format.json { render :json => @edition.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end
  
  def update
    @edition = Edition.find(params[:id])
    respond_to do |format|
      if @edition.update_attributes(params[:edition])
        format.json { render :json => @edition.get_hash }
      else
        format.json { render :json => @edition.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @edition = Edition.find(params[:id])
    @edition.destroy
    respond_to do |format|
      format.json { render :json => { :success => true }}
    end
  end
  
end
