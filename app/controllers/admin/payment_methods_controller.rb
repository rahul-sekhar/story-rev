class Admin::PaymentMethodsController < Admin::ApplicationController
  
  def index
    @payment_methods = PaymentMethod.scoped
    respond_to do |f|
      f.json do
        @payment_methods = @payment_methods.name_like(params[:q]).limit(10) if params[:q]
        render :json => @payment_methods, :only => [:id, :name]
      end
    end
  end
  
end
