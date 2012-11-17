class CustomerPresenter < BasePresenter
  presents :customer

  delegate :name,
    :phone,
    :email,
    :other_info,
    :city,
    :notes,
    :payment_method_id,
    :delivery_method,
    :pickup_point_short_text,
    to: :customer

  def pickup_point_text
    return "" if customer.delivery_method != 2
    
    "Pickup point: #{pickup_point_short_text}"
  end
  
  def payment_text
    "Payment by #{customer.payment_method.name.downcase}"
  end
  
  def delivery_text
    case customer.delivery_method.to_i
    when 1
      "Delivery by courier"
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

  def formatted_other_info
    simple_format h(other_info), class: :comments
  end

  def formatted_full_address
    if full_address.present?
      simple_format h(full_address), class: :address
    end
  end
end