class BookType < ActiveRecord::Base
  attr_accessible :name, :priority
  has_many :books, dependent: :restrict
  has_many :default_cost_prices, dependent: :destroy
  
  validates :name, 
    length: { maximum: 100 },
    presence: true,
    uniqueness: { case_sensitive: false }

  strip_attributes
  
  scope :prioritised, order("priority DESC, name")
  scope :visible, where("priority > 0")

  def self.columns_list
    column_names.collect { |c| "#{table_name}.#{c}" }.join(",")
  end
end
