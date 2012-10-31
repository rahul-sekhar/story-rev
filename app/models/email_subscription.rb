class EmailSubscription < ActiveRecord::Base
  attr_accessible :email

  validates :email, 
    presence: { message: "Please enter an email address" }, 
    format: { with: /.+@.+\..+/, message: "Invalid email address" }, 
    uniqueness: { message: "You have already subscribed" }

  def error_message
    errors[:email].first if invalid? && errors[:email].present?
  end
end
