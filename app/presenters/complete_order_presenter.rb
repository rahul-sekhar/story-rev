class CompleteOrderPresenter < OrderPresenter
  delegate :number_of_copies, to: :order

  def confirmed_check_box
    check_box("confirmed")
  end

  def paid_check_box
    check_box("paid")
  end

  def packaged_check_box
    check_box("packaged")
  end

  def posted_check_box
    check_box("posted")
  end

  def edit_link(text)
    link_to text, edit_admin_customer_path(order.customer), class: "edit-link"
  end

  def formatted_date
    order.confirmed_date.strftime("%b %e, %Y")
  end

  def timestamp
    order.confirmed_date.to_i
  end

  def formatted_postage_expenditure
    CurrencyMethods.formatted_currency(order.postage_expenditure || 0)
  end

  def as_hash
    {
      name: name,
      email: customer.email,
      address: customer.full_address || "",
      phone: customer.phone || "",
      other_info: customer.other_info || "",
      payment_text: customer.payment_text,
      delivery_text: customer.delivery_text,
      pickup_point_text: customer.pickup_point_text || "",
      postage_amount: formatted_postage_amount,
      postage_expenditure: formatted_postage_expenditure,
      postage_expenditure_val: order.postage_expenditure,
      total_amount: formatted_total_amount,
      notes: customer.notes || "",
      formatted_date: formatted_date,
      timestamp: timestamp
    }
  end

  def get_url
    # Check to see if the order is pending or completed
    if (order.confirmed && order.paid && order.posted)
      return admin_orders_url(host: Rails.application.config.default_host, selected_id: order.id)
    else
      return pending_admin_orders_url(host: Rails.application.config.default_host, selected_id: order.id)
    end 
  end

  private

  def check_box(attrib)
    check_box_tag(attrib, "1", order.send(attrib), :id => nil, class: attrib) + attrib
  end
end