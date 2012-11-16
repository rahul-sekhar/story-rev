class OrderPresenter < BasePresenter
  presents :order

  delegate :name, 
    :city, 
    :delivery_short,
    :delivery_text,
    :pickup_point_text,
    :delivery_method,
    :payment_method_id,
    :pickup_point_short_text,
    to: :customer

  delegate :total_amount, to: :order
  
  def number
    order.id
  end

  def formatted_postage_amount
    CurrencyMethods.formatted_currency(order.postage_amount || 0)
  end
  
  def formatted_total_amount
    CurrencyMethods.formatted_currency(order.total_amount || 0)
  end

  private

  def customer
    present(order.customer)
  end
end