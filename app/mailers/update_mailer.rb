class UpdateMailer < ActionMailer::Base
  default from: "\"Story Revolution\" <contact@storyrevolution.in>"
  
  def subscribe_mail(email)
    mail(:to => email, :subject => "You are subscribed to updates")
  end
  
  def notify_owner(email)
    @email = email
    mail(:to => "\"Story Revolution\" <contact@storyrevolution.in>", :subject => "Subscription from #{email}")
  end
end
