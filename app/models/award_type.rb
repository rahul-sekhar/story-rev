class AwardType < ActiveRecord::Base
  has_many :awards, :dependent => :destroy
  
  validates :name, :length => { :maximum => 100 }, :presence => true
end
