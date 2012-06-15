class Publisher < ActiveRecord::Base
  has_many :editions, :dependent => :nullify
  has_many :books, :dependent => :nullify
  
  validates :name, :length => { :maximum => 150 }, :presence => true
  
  scope :prioritised, order("priority DESC, name")
  scope :visible, where("priority > 0")
  
  def self.name_like(data)
    where("LOWER(name) like ?", "%#{SqlHelper::escapeWildcards(data.downcase)}%")
  end
  
  def self.name_is(data)
    where("LOWER(name) = ?", data.downcase)
  end
end
