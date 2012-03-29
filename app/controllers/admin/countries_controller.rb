class Admin::CountriesController < Admin::ApplicationController
  
  def index
    @countries = Country.select("id, name")
    respond_to do |f|
      f.json do
        @countries = @countries.name_like(params[:q]).limit(10) if params[:q]
        render :json => @countries, :only => [:id, :name]
      end
    end
  end
  
end
