class Illustrator < ActiveRecord::Base
  include Person
  attr_accessible :name, :priority

  validates :first_name, length: { maximum: 100 }
  validates :last_name, length: { maximum: 100 }, presence: true
  
  has_many :books, :dependent => :nullify
  
  scope :prioritised, order("priority DESC, last_name, first_name")
  scope :visible, where("priority > 0")
end
