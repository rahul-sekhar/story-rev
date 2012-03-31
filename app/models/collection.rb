class Collection< ActiveRecord::Base
  include Tag
  
  has_and_belongs_to_many :products, :join_table => :products_collections, :uniq => true
  
  validates :name, :length => { :maximum => 200 }, :presence => true, :uniqueness => { :case_sensitive => false }
  
  scope :prioritised, order("priority DESC")
  scope :visible, where("priority >= 0")
  
  def get_hash
    {
      :id => id,
      :name => name,
      :priority => priority
    }
  end
end
