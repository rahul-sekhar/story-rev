class Admin::LanguagesController < Admin::ApplicationController
  
  def index
    @languages = Language.select("id, name")
    respond_to do |f|
      f.json do
        @languages = @languages.name_like(params[:q]).limit(10) if params[:q]
        render :json => @languages, :only => [:id, :name]
      end
    end
  end
  
end
