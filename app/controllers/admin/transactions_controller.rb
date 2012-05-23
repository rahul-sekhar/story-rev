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
  end
end