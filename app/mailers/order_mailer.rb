class OrderMailer < ActionMailer::Base
  default from: "\"Story Revolution\" <contact@storyrevolution.in>"
  
  def confirmation(order)
    @order = order
    mail(:to => "\"#{@order.name}\" <#{@order.email}>", :subject => "Order confirmation")
  end
  
  def notify_owner(order)
    @order = order
    mail(:from => "\"#{@order.name}\" <#{@order.email}>", :to => "\"Story Revolution\" <contact@storyrevolution.in>", :subject => "Story Revolution Order")
  end
end
