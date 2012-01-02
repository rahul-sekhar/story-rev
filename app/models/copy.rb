class Copy < ActiveRecord::Base
  belongs_to :edition
  validates :accession_id, :presence => true, :uniqueness => true
  validates :condition_rating, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 5 }
  
end
