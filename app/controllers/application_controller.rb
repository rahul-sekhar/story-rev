class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :shopping_cart

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
end
