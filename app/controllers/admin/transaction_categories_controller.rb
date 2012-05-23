class Admin::TransactionCategoriesController < Admin::ApplicationController
  
  def index
    @categories = TransactionCategory.scoped
    respond_to do |f|
      f.json do
        @categories = @categories.name_like(params[:q]).limit(10) if params[:q]
        render :json => @categories, :only => [:id, :name, :off_record]
      end
    end
  end
  
end
