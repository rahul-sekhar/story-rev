class AccountPresenter < BasePresenter
  presents :account

  def formatted_amount_due
    CurrencyMethods.formatted_currency(account.amount_due)
  end

  def as_hash
    {
      id: account.id,
      name: account.name,
      amount_due: account.amount_due,
      formatted_amount_due: formatted_amount_due
    }
  end
end