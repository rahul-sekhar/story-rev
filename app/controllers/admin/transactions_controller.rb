class Admin::TransactionsController < Admin::ApplicationController
  before_filter :require_admin
  
  def index
    @title = "Finances Details"
    @class = "finances details"
    
    @transactions = Transaction.all
  end
  
  def summarised
    @title = "Finances Summary"
    @class = "finances summary"
    
    @transactions = Transaction.all
    
    @income = @transactions.map{ |x| x.credit }.inject(:+)
    @expenditure = @transactions.map{ |x| x.debit }.inject(:+)
    @profit = @income - @expenditure
    
    @accounts = Account.all
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