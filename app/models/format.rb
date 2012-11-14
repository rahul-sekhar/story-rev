class Format < ActiveRecord::Base
  extend FindableByName
  
  attr_accessible :name
  
  has_many :editions, :dependent => :nullify
  
  validates :name,
    length: { maximum: 100 },
    presence: true,
    uniqueness: { case_sensitive: false }
  
  strip_attributes

  def self.columns_list
    column_names.collect { |c| "#{table_name}.#{c}" }.join(",")
  end
end
