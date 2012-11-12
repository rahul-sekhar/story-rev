class OrderPresenter < BasePresenter
  presents :order

  def formatted_postage_amount
    CurrencyMethods.to_currency(order.postage_amount || 0)
  end
  
  def formatted_total_amount
    CurrencyMethods.to_currency(order.total_amount || 0)
  end
  
  def formatted_postage_expenditure
    CurrencyMethods.to_currency(order.postage_expenditure || 0)
  end
end