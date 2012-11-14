class ConfigData < ActiveRecord::Base
  attr_accessible
  
  before_save :check_number
  
  validates :default_cost_price, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }

  validates :default_percentage, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100
  }
  
  def check_number
    return false if self.class.count > 0 && new_record?
  end
  
  def self.access
    self.first || self.create
  end
end
