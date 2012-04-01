class OrderMailer < ActionMailer::Base
  default from: "aragornhasufel@gmail.com"
  
  def test_email
    mail(:to => "sekhar.rahul@gmail.com", :subject => "Testing out!")
  end
end
