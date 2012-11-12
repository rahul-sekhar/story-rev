class CustomerPresenter < BasePresenter
  presents :customer

  delegate :name, to: :customer
  delegate :phone, to: :customer
  delegate :email, to: :customer
  delegate :other_info, to: :customer

  def pickup_point_text
    return "" if customer.delivery_method != 2
    
    "Pickup point: #{pickup_point_short_text}"
  end
  
  def pickup_point_short_text
    customer.pickup_point.present? ? customer.pickup_point.name : "#{customer.other_pickup} (other)"
  end
  
  def payment_text
    "Payment by #{customer.payment_method.name.downcase}"
  end
  
  def delivery_text
    case customer.delivery_method.to_i
    when 1
      "Delivery by speed post"
    when 2
      "Delivery by pickup"
    end
  end

  def delivery_short
    case customer.delivery_method.to_i
    when 1
      "Post"
    when 2
      "Pick-up"
    end
  end
  
  def full_address
    x = customer.address.to_s
    x += "\n" if customer.address.present? && (customer.city.present? || customer.pin_code.present?)
    x += customer.city if customer.city.present?
    x += " - " if (customer.city.present? && customer.pin_code.present?)
    x += customer.pin_code if customer.pin_code.present?
    return x
  end
end