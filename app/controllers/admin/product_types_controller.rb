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
  
end
