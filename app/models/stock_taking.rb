class StockTaking < ActiveRecord::Base
  self.table_name = :stock_taking
  
  attr_accessible :copy_id
  
  belongs_to :copy
  validates :copy, presence: true
end