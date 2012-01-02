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
  
end
