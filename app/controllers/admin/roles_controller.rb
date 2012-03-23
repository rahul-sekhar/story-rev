class Admin::RolesController < Admin::ApplicationController

  def index
    @class = "passwords"
    @title = "Passwords"
    @roles = Admin::Role.order(:created_at)
  end
  
  def update
    @role = Admin::Role.find(params[:id])
    if @role.update_attributes(params[:admin_role])
      redirect_to admin_roles_path, :notice => "The #{@role.name} password has been changed."
    else
      redirect_to admin_roles_path, :notice => "Invalid password."
    end
  end
end
