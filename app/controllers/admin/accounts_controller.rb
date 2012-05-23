class Admin::AccountsController < Admin::ApplicationController
  
  def index
    @accounts = Account.scoped
    respond_to do |f|
      f.json do
        @accounts = @accounts.name_like(params[:q]).limit(10) if params[:q]
        render :json => @accounts, :only => [:id, :name]
      end
    end
  end
  
end
