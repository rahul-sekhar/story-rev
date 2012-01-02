class Admin::GenresController < Admin::ApplicationController
  
  def index
    @genres = Genre.select("id, name")
    respond_to do |format|
      format.json do
        @genres = @genres.name_like(params[:q]).limit(10) if params[:q]
        render :json => @genres.map {|x| { :id => x.id, :name => x.name } }
      end
    end
  end
  
end
