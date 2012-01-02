class Admin::IllustratorsController < Admin::ApplicationController
  
  def index
    @illustrators = Illustrator.select("id, first_name, last_name")
    respond_to do |format|
      format.json do
        @illustrators = @illustrators.name_like(params[:q]).limit(10) if params[:q]
        render :json => @illustrators.map {|x| { :id => x.id, :name => x.full_name } }
      end
    end
  end
  
end
