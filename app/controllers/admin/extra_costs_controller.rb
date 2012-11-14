class Admin::ExtraCostsController < Admin::ApplicationController
  def index
    @extra_costs = CompleteOrder.find(params[:order_id]).extra_costs
    
    render json: @extra_costs.map{ |x| present(x).as_hash }
  end

  def create
    @order = CompleteOrder.find(params[:order_id])
    @extra_cost =  @order.extra_costs.build(params[:extra_cost])
    if @extra_cost.save
      render json: present(@extra_cost).as_hash
    else
      render json: @extra_cost.errors.full_messages, status: :unprocessable_entity
    end
  end
  
  def update
    @extra_cost =  ExtraCost.find(params[:id])
    if @extra_cost.update_attributes(params[:extra_cost])
      render json: present(@extra_cost).as_hash
    else
      render json: @extra_cost.errors.full_messages, status: :unprocessable_entity
    end
  end
  
  def destroy
    @extra_cost =  ExtraCost.find(params[:id])
    @extra_cost.destroy
    render json: present(@extra_cost).as_hash
  end
end