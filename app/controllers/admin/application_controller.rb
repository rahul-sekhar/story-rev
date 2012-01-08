class Admin::ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :require_login
  helper_method :admin_role
  
  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    clear_return_to
  end
  
  def store_location
    session[:return_to] = request.fullpath
  end
  
  def store_location_from
    session[:return_to] = request.referer
  end

  def clear_return_to
    session[:return_to] = nil
  end
  
  private
  
  def admin_role
    @admin_role ||= session[:admin_role] if session[:admin_role]
  end
  
  def require_login
    unless admin_role
      store_location
      redirect_to admin_login_path, :alert => "You must sign in first"
    end
  end
  
  def require_admin
    unless admin_role == 'admin'
      redirect_to admin_root_url, :alert => "You cannot access that page"
    end
  end
end
