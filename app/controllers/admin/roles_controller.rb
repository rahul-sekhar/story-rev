class Admin::RolesController < Admin::ApplicationController
  before_filter :require_admin
  
  def index
    @class = "passwords"
    @title = "Passwords"
    @roles = Admin::Role.order(:created_at)
    @discount_percentage = ConfigData.access.discount_percentage
  end
  
  def update
    @role = Admin::Role.find(params[:id])
    if @role.update_attributes(params[:admin_role])
      redirect_to admin_roles_path, :notice => "The #{@role.name} password has been changed."
    else
      redirect_to admin_roles_path, :notice => "Invalid password."
    end
  end

  def set_discount_percentage
    config = ConfigData.access
    config.discount_percentage = params[:discount_percentage]
    if config.save
      redirect_to admin_roles_path, notice: "The store-wide discount percentage has been changed"
    else
      redirect_to admin_roles_path, alert: "Invalid entry"
    end
  end
end
