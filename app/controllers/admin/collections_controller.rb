class Admin::KeywordsController < Admin::ApplicationController
  
  def index
    @keywords = Keyword.select("id, name")
    respond_to do |format|
      format.json do
        @keywords = @keywords.name_like(params[:q]).limit(10) if params[:q]
        render :json => @keywords.map {|x| { :id => x.id, :name => x.name } }
      end
    end
  end
  
end
