class ProductAward < ActiveRecord::Base
  self.table_name = :products_awards
  
  belongs_to :product
  belongs_to :award
  
  validates :product_id, :presence => true
  validates :award_id, :presence => true
  validates :year, :numericality => { :only_integer => true, :greater_than => 1000, :less_than => 2100 }, :allow_blank => true
end
