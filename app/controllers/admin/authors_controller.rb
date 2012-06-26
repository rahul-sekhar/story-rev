class Admin::AuthorsController < Admin::ApplicationController
  def index
    @authors = Author.select("id, first_name, last_name")
    respond_to do |format|
      format.json do
        @authors = @authors.name_like(params[:q]).limit(10) if params[:q]
        render :json => @authors.map {|x| { :id => x.id, :name => x.name } }
      end
    end
  end
  
  def update
    @author = Author.find(params[:id])
    if @author.update_attributes(params[:author])
      render :json => { :success => true }
    else
      render :json => @author.errors.full_messages, :status => :unprocessable_entity
    end
  end
end
