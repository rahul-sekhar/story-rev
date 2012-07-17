class Admin::ExtraCostsController < Admin::ApplicationController
  def index
    @extra_costs = Order.find(params[:order_id]).extra_costs
    
    render :json => @extra_costs.map {|x| x.get_hash}
  end

  def create
    @order = Order.find(params[:order_id])
    @extra_cost =  @order.extra_costs.build(params[:extra_cost])
    if @extra_cost.save
      @order.save
      render :json => @extra_cost.get_hash
    else
      render :json => @extra_cost.errors.full_messages, :status => :unprocessable_entity
    end
  end
  
  def update
    @extra_cost =  ExtraCost.find(params[:id])
    if @extra_cost.update_attributes(params[:extra_cost])
      @extra_cost.order.save
      render :json => @extra_cost.get_hash
    else
      render :json => @extra_cost.errors.full_messages, :status => :unprocessable_entity
    end
  end
  
  def destroy
    @extra_cost =  ExtraCost.find(params[:id])
    @extra_cost.destroy
    @extra_cost.order.save
    render :json => @extra_cost.get_hash
  end
end