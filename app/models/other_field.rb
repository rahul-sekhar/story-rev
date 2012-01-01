class OtherField < ActiveRecord::Base
  default_scope :order => "created_at ASC"
  belongs_to :product
  
  validates :title, :length => { :maximum => 200 }, :presence => true
  validates :content, :presence => true
end
