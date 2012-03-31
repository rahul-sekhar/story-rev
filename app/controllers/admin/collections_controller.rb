class Admin::CollectionsController < Admin::ApplicationController
  
  def index
    @collections = Collection.prioritised
    @class = "collections"
    @title = "Collections"
    
    respond_to do |format|
      format.html
      format.json do
        @collections = @collections.name_like(params[:q]).limit(10) if params[:q]
        render :json => @collections.map {|x| x.get_hash }
      end
    end
  end
  
  def create
    @collection = Collection.new(params[:collection])
    if @collection.save
      render :json => @collection.get_hash
    else
      render :json => @collection.errors.full_messages, :status => :unprocessable_entity
    end
  end
  
  def update
    @collection = Collection.find(params[:id])
    if @collection.update_attributes(params[:collection])
      render :json => @collection.get_hash
    else
      render :json => @collection.errors.full_messages, :status => :unprocessable_entity
    end
  end
  
  def destroy
    @collection = Collection.find(params[:id])
    @collection.destroy
    render :json => { :success => true }
  end
end
