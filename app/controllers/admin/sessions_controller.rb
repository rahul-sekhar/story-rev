class Admin::SessionsController < Admin::ApplicationController
  skip_before_filter :require_login, :only => [:new, :create]
  
  def new
    redirect_to admin_root_path if admin_role
  end
  
  def create
    role = Admin::Role.authenticate(params[:password])
    if (role)
      session[:admin_role] = role
      redirect_back_or admin_root_path
    else
      flash.now.alert = "Invalid password"
      render "new"
    end
  end
  
  def destroy
    session[:admin_role] = nil
    redirect_to admin_root_url, :notice => "Logged out successfully"
  end
end
