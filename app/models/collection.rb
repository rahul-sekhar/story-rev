class Collection< ActiveRecord::Base
  include Tag
  
  has_and_belongs_to_many :products, :join_table => :products_collections, :uniq => true
  
  validates :name, :length => { :maximum => 100 }, :presence => true, :uniqueness => { :case_sensitive => false }
end
