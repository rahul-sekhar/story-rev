class ConfigData < ActiveRecord::Base
  before_save :check_number
  
  belongs_to :default_account, :class_name => "Account"
  belongs_to :cash_account, :class_name => "Account"
  
  def check_number
    return false if self.class.count > 0 && new_record?
  end
  
  def self.access
    self.first || self.create
  end
end
