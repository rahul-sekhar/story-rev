class Admin::PublishersController < Admin::ApplicationController
  
  def index
    @publishers = Publisher.select("id, name")
    respond_to do |format|
      format.json do
        @publishers = @publishers.name_like(params[:q]).limit(10) if params[:q]
        render :json => @publishers.map {|x| { :id => x.id, :name => x.name } }
      end
    end
  end
  
  def update
    @publisher = Publisher.find(params[:id])
    if @publisher.update_attributes(params[:publisher])
      render :json => { :success => true }
    else
      render :json => @publisher.errors.full_messages, :status => :unprocessable_entity
    end
  end
end
