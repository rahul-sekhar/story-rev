class Admin::ProductTypesController < Admin::ApplicationController
  
  def create
    @product_type = ProductType.new(params[:product_type])
    respond_to do |format|
      if @product_type.save
        format.json { render :json => @product_type, :only => [:id, :name] }
      else
        format.json { render :json => @product_type.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end
  
  def update
    @product_type = ProductType.find(params[:id])
    if @product_type.update_attributes(params[:product_type])
      render :json => { :success => true }
    else
      render :json => @product_type.errors.full_messages, :status => :unprocessable_entity
    end
  end
  
end
