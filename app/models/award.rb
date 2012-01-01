class Award < ActiveRecord::Base
  default_scope :order => "created_at ASC"
  belongs_to :award_type
  has_many :product_awards, :dependent => :destroy
  
  validates :name, :length => { :maximum => 150 }, :presence => true
end
