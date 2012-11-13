class OrderPresenter < BasePresenter
  presents :order

  delegate :name, to: :customer
  delegate :city, to: :customer
  delegate :delivery_short, to: :customer

  def number
    order.id
  end

  def delivery_method
    order.customer.delivery_method
  end

  def formatted_postage_amount
    CurrencyMethods.to_currency(order.postage_amount || 0)
  end
  
  def formatted_total_amount
    CurrencyMethods.to_currency(order.total_amount || 0)
  end

  private

  def customer
    present(order.customer)
  end
end