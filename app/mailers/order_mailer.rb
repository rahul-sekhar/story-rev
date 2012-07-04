class OrderMailer < ActionMailer::Base
  default from: "\"Story Revolution\" <contact@storyrevolution.in>"
  
  def confirmation(order, email_to = nil)
    @order = order

    email_to = "\"#{@order.name}\" <#{@order.email}>" unless email_to
    mail(:to => email_to, :subject => "Order confirmation")
  end
  
  def notify_owner(order)
    @order = order
    mail(:from => "\"#{@order.name}\" <#{@order.email}>", :to => "\"Story Revolution\" <contact@storyrevolution.in>", :subject => "Story Revolution Order")
  end
end
