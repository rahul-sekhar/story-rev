class Admin::TransactionsController < Admin::ApplicationController
  include TransactionDates

  before_filter :require_admin
  
  def index
    @title = "Finances Details"
    @class = "finances details"
    
    get_dates

    @transactions = Transaction.between(@date_from, @date_to)
    
    respond_to do |format|
      format.html { @transfers = Transfer.between(@date_from, @date_to) }
      format.json { render :json => @transactions.map { |x| x.get_hash }}
    end
  end
  
  def summarised
    @title = "Finances Summary"
    @class = "finances summary"
    
    get_dates(1.year)
    
    @transactions = Transaction.on_record.between(@date_from, @date_to)
    
    @income = @transactions.inject(0){|total, x| total + x.credit}
    @expenditure = @transactions.inject(0){|total, x| total + x.debit}
    @profit = @income - @expenditure
    
    respond_to do |format|
      format.html {
        @accounts = Account.all
      }
      format.json {
        render :json => {
          :income => RupeeHelper.format_rupee(@income),
          :expenditure => RupeeHelper.format_rupee(@expenditure),
          :profit => RupeeHelper.format_rupee(@profit)
        }
      }
    end
  end
  
  def graph_data
    render :json => Transaction.graph_data(params[:period], params[:type], params[:from], params[:to])
  end
  
  def create
    @transaction = Transaction.new(params[:transaction])
    
    respond_to do |format|
      if @transaction.save
        format.json {render :json => @transaction.get_hash }
      else
        format.json { render :json => @transaction.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end
  
  def update
    @transaction = Transaction.find(params[:id])
    respond_to do |format|
      if @transaction.update_attributes(params[:transaction])
        format.json { render :json => @transaction.get_hash }
      else
        format.json { render :json => @transaction.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @transaction = Transaction.find(params[:id])
    @transaction.destroy
    respond_to do |format|
      format.json { render :json => { :success => true }}
    end
  end
end