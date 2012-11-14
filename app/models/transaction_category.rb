class TransactionCategory < ActiveRecord::Base
  extend FindableByName
  
  attr_accessible :name
  
  has_many :transactions, dependent: :restrict
  
  validates :name, length: { maximum: 120 }, presence: true, uniqueness: { case_sensitive: false }

  strip_attributes

  def self.find_or_create(name)
    name_is(name) || create(name: name)
  end
end
