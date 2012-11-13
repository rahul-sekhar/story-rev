class ConfigData < ActiveRecord::Base
  attr_accessible
  
  before_save :check_number
  
  belongs_to :default_account, :class_name => "Account"
  belongs_to :cash_account, :class_name => "Account"
  validates :default_cost_price, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }
  
  def check_number
    return false if self.class.count > 0 && new_record?
  end
  
  def self.access
    self.first || self.create
  end
end
