class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :shopping_cart

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
  
  def shopping_cart
    begin
      @shopping_cart ||= (session[:shopping_cart_id] && ShoppingCart.find(session[:shopping_cart_id])) || ShoppingCart.new
    rescue
      session[:shopping_cart_id] = nil
      @shopping_cart = ShoppingCart.new
    end
  end
  
  def store_shopping_cart
    shopping_cart.save
    session[:shopping_cart_id] = shopping_cart.id
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
