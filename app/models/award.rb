class Award < ActiveRecord::Base
  belongs_to :award_type
  has_many :product_awards, :dependent => :destroy
  
  validates :name, :length => { :maximum => 150 }, :presence => true
end
