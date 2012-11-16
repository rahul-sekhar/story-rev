class LoanPresenter < BasePresenter
  presents :loan

  delegate :id,
    :amount, 
    :name, 
    to: :loan

  def formatted_amount
    CurrencyMethods.formatted_currency(amount)
  end

  def formatted_date
    loan.created_at.strftime("%b %e, %Y")
  end

  def timestamp
    loan.created_at.to_i
  end

  def as_hash
    {
      id: id,
      name: name,
      formatted_date: formatted_date,
      timestamp: timestamp,
      formatted_amount: formatted_amount,
      amount: amount
    }
  end
end