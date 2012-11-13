class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :order

  # Error handling
  if Rails.application.config.show_error_pages
    rescue_from Exception, with: lambda { |exception| render_error 500, exception }
    rescue_from ActionController::RoutingError, ActionController::UnknownController, ::AbstractController::ActionNotFound, ActiveRecord::RecordNotFound, with: lambda { |exception| render_error 404, exception }
  end

  # Access to presenters
  def present(object, klass = nil)
    klass ||= "#{object.class}Presenter".constantize
    klass.new(object, view_context)
  end
  
  def order
    @order ||= Order.find_by_id(session[:order_id])
    if @order.nil?
      session.delete(:order_id)
      @order = Order.new
    end
    return @order
  end
  
  def store_order
    order.save
    session[:order_id] = order.id
  end

  private
  def render_error(status, exception)
    respond_to do |format|
      @class = "error-page"
      @title = nil
      format.html { render template: "errors/error_#{status}", layout: 'layouts/application', status: status }
      format.all { render nothing: true, status: status }
    end
  end
end
