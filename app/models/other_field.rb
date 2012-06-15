class OtherField < ActiveRecord::Base
  default_scope :order => "created_at ASC"
  belongs_to :book
  
  validates :title, :length => { :maximum => 200 }, :presence => true
end
