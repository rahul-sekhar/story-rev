class Publisher < ActiveRecord::Base
  extend FindableByName
  
  attr_accessible :name
  
  has_many :editions, dependent: :nullify
  has_many :books, dependent: :nullify
  has_many :default_percentages, dependent: :destroy
  
  validates :name, 
    length: { maximum: 150 }, 
    presence: true,
    uniqueness: { case_sensitive: false }

  strip_attributes
  
  scope :prioritised, order("priority DESC, name")
  scope :visible, where("priority > 0")
end
