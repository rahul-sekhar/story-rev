class StockTaking < ActiveRecord::Base
  attr_accessible :copy_id
  
  belongs_to :copy
end