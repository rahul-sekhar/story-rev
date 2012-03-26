class Admin::StocksController < Admin::ApplicationController
  def add_copy
    @stock = Stock.create(:copy_id => params[:copy_id])
    
    render :json => { :stock => Copy.find(params[:copy_id]).stock.present? }
  end
  
  def remove_copy
    Stock.find_by_copy_id(params[:copy_id]).destroy
    
    render :json => { :stock => Copy.find(params[:copy_id]).stock.present? }
  end
  
  def clear
    Stock.all.each do |s|
      s.destroy
    end
    
    redirect_to admin_products_path
  end
end