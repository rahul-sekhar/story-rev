class Admin::TransactionsController < Admin::ApplicationController
  include TransactionDates

  before_filter :require_admin
  
  def index
    @title = "Finances Details"
    @class = "finances details"
    
    get_dates

    @transactions = Transaction.between(@date_from, @date_to)
    
    respond_to do |format|
      format.html
      format.json { render json: @transactions.map { |x| present(x).as_hash }}
    end
  end
  
  def summarised
    @title = "Finances Summary"
    @class = "finances summary"
    
    get_dates(1.year)
    
    @transactions = Transaction.between(@date_from, @date_to)
    
    @income = @transactions.inject(0){|total, x| total + x.credit}
    @expenditure = @transactions.inject(0){|total, x| total + x.debit}
    @profit = @income - @expenditure
    
    respond_to do |format|
      format.html { @accounts = Account.all }
      format.json {
        render json: {
          income: CurrencyMethods.formatted_currency(@income),
          expenditure: CurrencyMethods.formatted_currency(@expenditure),
          profit: CurrencyMethods.formatted_currency(@profit)
        }
      }
    end
  end
  
  def graph_data
    render json: Transaction.graph_data(params[:period], params[:type], params[:from], params[:to])
  end
  
  def create
    @transaction = Transaction.new(params[:transaction])
    
    respond_to do |format|
      if @transaction.save
        format.json {render json: present(@transaction).as_hash }
      else
        format.json { render json: @transaction.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end
  
  def update
    @transaction = Transaction.find(params[:id])
    respond_to do |format|
      if @transaction.update_attributes(params[:transaction])
        format.json { render json: present(@transaction).as_hash }
      else
        format.json { render json: @transaction.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @transaction = Transaction.find(params[:id])
    @transaction.destroy
    respond_to do |format|
      format.json { render json: { success: true }}
    end
  end
end