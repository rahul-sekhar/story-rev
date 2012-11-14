class OrderMailer < ActionMailer::Base
  default from: "\"Story Revolution\" <contact@storyrevolution.in>"
  
  def confirmation(order, email_to = nil)
    @order = order
    @customer = @order.customer

    email_to = "\"#{@customer.name}\" <#{@customer.email}>" unless email_to
    mail(to: email_to, subject: "Order confirmation")
  end
  
  def notify_owner(order)
    @order = order
    @customer = @order.customer
    
    mail(from: "\"#{@customer.name}\" <#{@customer.email}>", to: "contact@storyrevolution.in", subject: "Story Revolution Order")
  end
end
