class Stock < ActiveRecord::Base
  self.table_name = :stock_taking
  
  belongs_to :copy
end