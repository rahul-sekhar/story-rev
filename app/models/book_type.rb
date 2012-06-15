class BookType < ActiveRecord::Base
  has_many :books
  
  validates :name, :length => { :maximum => 100 }, :presence => true, :uniqueness => { :case_sensitive => false }
  
  scope :prioritised, order("priority DESC, name")
  scope :visible, where("priority > 0")
end
