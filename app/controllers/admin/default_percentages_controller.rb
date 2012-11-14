class Admin::DefaultPercentagesController < Admin::ApplicationController
  def create
    @dcp = DefaultPercentage.new(params[:default_percentage])
    flash[:book_type_id] = params[:default_percentage][:book_type_id]
    if @dcp.save
      redirect_to admin_default_cost_prices_path(anchor:"percentages-section"), notice: "Entry added"
    else
      redirect_to admin_default_cost_prices_path(anchor:"percentages-section"), alert: "Invalid entry"
    end
  end

  def set_default
    config = ConfigData.access
    config.default_percentage = params[:default_percentage]
    if config.save
      redirect_to admin_default_cost_prices_path(anchor:"percentages-section"), notice: "The default percentage has been changed"
    else
      redirect_to admin_default_cost_prices_path(anchor:"percentages-section"), alert: "Invalid entry"
    end
  end

  def destroy
    @dcp = DefaultPercentage.find(params[:id])
    @dcp.destroy
    redirect_to admin_default_cost_prices_path(anchor:"percentages-section")
  end
end