class Admin::StockTakingController < Admin::ApplicationController
  def add_copy
    StockTaking.create(copy_id: params[:copy_id])
    render json: { stock: Copy.find(params[:copy_id]).stock_taking.present? }
  end
  
  def remove_copy
    StockTaking.find_by_copy_id(params[:copy_id]).destroy
    render json: { stock: Copy.find(params[:copy_id]).stock_taking.present? }
  end
  
  def clear
    StockTaking.all.each do |s|
      s.destroy
    end
    
    redirect_to admin_books_path
  end
end