class ExtraCostPresenter < BasePresenter
  presents :extra_cost

  def as_hash
    {
      id: extra_cost.id,
      name: extra_cost.name,
      amount: extra_cost.amount,
      formatted_amount: CurrencyMethods.formatted_currency(extra_cost.amount),
      expenditure: extra_cost.expenditure,
      formatted_expenditure: CurrencyMethods.formatted_currency(extra_cost.expenditure),
      total_amount: order.formatted_total_amount,
      postage_amount: order.formatted_postage_amount
    }
  end

  def order
    present(extra_cost.order)
  end
end