class Admin::AuthorsController < Admin::ApplicationController
  def index
    @authors = Author.select("id, first_name, last_name")
    respond_to do |format|
      format.json do
        @authors = @authors.name_like(params[:q]).limit(10) if params[:q]
        render :json => @authors.map {|x| { :id => x.id, :name => x.full_name } }
      end
    end
  end
end
