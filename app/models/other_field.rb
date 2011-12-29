class OtherField < ActiveRecord::Base
  belongs_to :product
  
  validates :title, :length => { :maximum => 200 }, :presence => true
  validates :content, :presence => true
end
