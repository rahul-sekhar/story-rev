class Collection< ActiveRecord::Base
  include Tag

  attr_accessible :name, :priority
  
  has_and_belongs_to_many :books, join_table: :books_collections, uniq: true
  
  validates :name, 
    length: { :maximum => 200 },
    presence: true, 
    uniqueness: { case_sensitive: false }

  strip_attributes
  
  scope :prioritised, order("priority DESC")
  scope :visible, where("priority > 0")
  
  def as_hash
    {
      :id => id,
      :name => name,
      :priority => priority
    }
  end

  def self.columns_list
    column_names.collect { |c| "#{table_name}.#{c}" }.join(",")
  end
end
