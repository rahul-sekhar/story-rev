class Admin::ProductTagsController < Admin::ApplicationController
  
  def index
    @product_tags = ProductTag.select("id, name")
    respond_to do |format|
      format.json do
        @product_tags = @product_tags.name_like(params[:q]).limit(10) if params[:q]
        render :json => @product_tags.map {|x| { :id => x.id, :name => x.name } }
      end
    end
  end
  
end
