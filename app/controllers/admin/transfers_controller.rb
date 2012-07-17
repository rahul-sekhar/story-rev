class Admin::TransfersController < Admin::ApplicationController
  include TransactionDates
  
  before_filter :require_admin
  
  def index
    get_dates
    
    @transfers = Transfer.between(@date_from, @date_to)
    
    respond_to do |format|
      format.json { render :json => @transfers.map { |x| x.get_hash }}
    end
  end
  
  def create
    @transfer = Transfer.new(params[:transfer])
    
    respond_to do |format|
      if @transfer.save
        format.json {render :json => @transfer.get_hash }
      else
        format.json { render :json => @transfer.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end
  
  def update
    @transfer = Transfer.find(params[:id])
    respond_to do |format|
      if @transfer.update_attributes(params[:transfer])
        format.json { render :json => @transfer.get_hash }
      else
        format.json { render :json => @transfer.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @transfer = Transfer.find(params[:id])
    @transfer.destroy
    respond_to do |format|
      format.json { render :json => { :success => true }}
    end
  end
end