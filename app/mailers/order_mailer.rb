class OrderMailer < ActionMailer::Base
  default from: "\"Story Revolution\" <contact@storyrevolution.in>"
  
  def confirmation(order)
    @order = order
    mail(:to => "\"#{@order.name}\" <#{@order.email}>", :subject => "Order confirmation")
  end
end
