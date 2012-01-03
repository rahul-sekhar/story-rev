class Admin::FormatsController < Admin::ApplicationController
  
  def index
    @formats = Format.select("id, name")
    respond_to do |f|
      f.json do
        @formats = @formats.name_like(params[:q]).limit(10) if params[:q]
        render :json => @formats, :only => [:id, :name]
      end
    end
  end
  
end
