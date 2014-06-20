class Admin::StoreOpenController < Admin::ApplicationController
  def toggle
    config = ConfigData.access
    config.store_open = !config.store_open
    config.save
    redirect_to admin_roles_path
  end
end