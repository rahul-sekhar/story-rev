class Admin::DefaultCostPricesController < Admin::ApplicationController
  def index
    @title = "Configure Default Cost Prices"
    @class = "others dcp"
    @default = ConfigData.access.default_cost_price
    @default_percentage = ConfigData.access.default_percentage
    @dcps = DefaultCostPrice.all
    @dps = DefaultPercentage.all
    @new_dcp = DefaultCostPrice.new(book_type_id: flash[:book_type_id])
    @new_dp = DefaultPercentage.new
  end

  def create
    @dcp = DefaultCostPrice.new(params[:default_cost_price])
    flash[:book_type_id] = params[:default_cost_price][:book_type_id]
    if @dcp.save
      redirect_to admin_default_cost_prices_path, notice: "Entry added"
    else
      redirect_to admin_default_cost_prices_path, alert: "Invalid entry"
    end
  end

  def set_default
    config = ConfigData.access
    config.default_cost_price = params[:default_cost_price]
    if config.save
      redirect_to admin_default_cost_prices_path, notice: "The default cost price has been changed"
    else
      redirect_to admin_default_cost_prices_path, alert: "Invalid entry"
    end
  end

  def destroy
    @dcp = DefaultCostPrice.find(params[:id])
    @dcp.destroy
    redirect_to admin_default_cost_prices_path
  end
end