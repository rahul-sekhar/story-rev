class Product < ActiveRecord::Base
  
  has_and_belongs_to_many :keywords
  has_and_belongs_to_many :genres
  has_and_belongs_to_many :product_tags
  belongs_to :author
  belongs_to :illustrator
  belongs_to :publisher
  has_many :product_awards, :dependent => :destroy
  has_many :editions, :dependent => :destroy
  has_many :copies, :through => :editions
  has_many :other_fields, :dependent => :destroy
  
  validates :title, :presence => true, :length => { :maximum => 250 }, :uniqueness => true
  validates :author_id, :presence => true
  validates :age_from, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0, :less_than => 100 }, :allow_blank => true
  validates :age_to, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0, :less_than => 100 }, :allow_blank => true
  validates :year, :numericality => { :only_integer => true, :greater_than => 1000, :less_than => 2100 }, :allow_blank => true
  validates :flipkart_id, :length => { :maximum => 40 }
  validates :amazon_url, :length => { :maximum => 200 }
  validates :accession_id, :presence => true, :uniqueness => true
  
  validates_associated :author
  validates_associated :illustrator
  validates_associated :publisher
  validates_associated :product_awards
  validates_associated :other_fields
end
