module TransactionDates
  def get_dates(default_gap = 3.months)
    params.delete :to if params[:to].blank?
    params.delete :from if params[:from].blank?

    @first_transaction_date = Transaction.first_date
    
    @date_to = (params[:to] && Date.strptime(params[:to], "%d-%m-%Y")) || Date.today
    tentative_from = @date_to - default_gap
    @date_from = (params[:from] && Date.strptime(params[:from], "%d-%m-%Y")) || (@first_transaction_date > tentative_from) ? @first_transaction_date : tentative_from
  end
end