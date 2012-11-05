class Book < ActiveRecord::Base
  extend NameTags

  default_scope -> { includes(:author) }

  attr_accessible :title, :author_name, :illustrator_name, :publisher_name, 
  :year, :country_name, :age_from, :age_to, :collection_list, :amazon_url, 
  :short_description, :book_type_id, :award_attributes, 
  :description_attributes, :cover_image_id, :cover_image_url
  
  after_initialize :init
  after_validation :validate_virtual_attributes
  before_save :check_age_level, :set_accession_id
  after_create :set_book_date
  
  has_and_belongs_to_many :collections, 
    join_table: :books_collections, 
    uniq: true
  belongs_to :author
  belongs_to :illustrator
  belongs_to :publisher
  belongs_to :book_type
  belongs_to :country
  has_many :book_awards, :dependent => :destroy
  has_many :editions, :dependent => :destroy
  has_many :new_copies, :through => :editions
  has_many :used_copies, :through => :editions
  has_many :copies, :through => :editions, :readonly => true
  has_many :descriptions, :dependent => :destroy
  has_one :cover_image, :dependent => :destroy

  name_tag :author, :illustrator, :publisher, :country
  delegate :name, to: :book_type, prefix: true, allow_nil: true

  strip_attributes
  
  validates :title, 
    presence: true, 
    length: { maximum: 255 },
    uniqueness: { case_sensitive: false }

  validates :author, presence: true
  
  validates :age_from, 
    numericality: { 
      only_integer: true, 
      greater_than_or_equal_to: 0,
      less_than: 100 
    },
    allow_blank: true
  
  validates :age_to, 
    numericality: {
      only_integer: true,
      greater_than_or_equal_to: 0,
      less_than: 100
    }, 
  allow_blank: true
  
  validates :year,
    numericality: { 
      only_integer: true,
      greater_than_or_equal_to: 1000,
      less_than: 2100 
    },
    allow_blank: true
  
  validates :amazon_url, length: { maximum: 255 }
  
  validates :accession_id,
    uniqueness: true,
    numericality: {
      only_integer: true,
      greater_than_or_equal_to: 0 
    }, 
    allow_blank: true
  
  validates_associated :author
  validates_associated :illustrator
  validates_associated :publisher
  validates_associated :country
  validates_associated :book_type
  validates_associated :book_awards
  validates_associated :descriptions
  
  scope :stocked, where(in_stock: true)
  
  # Scope to include all book information
  def self.includes_data
    includes(:illustrator, :publisher, :collections, :copies, :book_type, :country, :descriptions, { :book_awards => { :award => :award_type }}, :editions => [:format, :publisher])
  end
  
  # Scope to include copy data
  def self.includes_copies
    includes({:editions => [:format, :publisher]}, :copies)
  end
  
  # Function to get a complete list of all table columns (can be used to select all columns in pure SQL)
  def self.columns_list
    column_names.collect { |c| "#{table_name}.#{c}" }.join(",")
  end
  
  def init
    self.in_stock = false if in_stock.nil?
  end

  def to_param
    accession_id
  end
  
  # Set the book date - triggered when the book is created, a used copy is created, or a new copy goes back in stock
  def set_book_date
    touch :book_date
  end
  
  def validate_virtual_attributes
    self.errors[:author_name] = errors[:author] if errors[:author].present?
    self.errors[:illustrator_name] = errors[:illustrator] if errors[:illustrator].present?
  end
  
  def check_age_level
    if (age_to && !age_from)
      self.age_from = age_to
    end
  end
  
  def set_accession_id
    self.accession_id ||= find_accession_id
  end
  
  def find_accession_id
    last_book = Book.where("accession_id IS NOT NULL").order("accession_id DESC").limit(1).first
    return last_book.present? ? last_book.accession_id.to_i + 1 : 1
  end
  
  def build_empty_fields
    if book_awards.length == 0
      self.book_awards.build
    end
    
    if descriptions.length == 0
      self.descriptions.build
    end
  end
  
  def collection_list
    collections.map{ |x| x.name }.join(", ")
  end
  def collection_list=(tag_list)
    self.collections = Collection.from_list(tag_list)
  end
  def collections_json
    collections.to_json({ :only => [:id, :name] })
  end
  
  def award_attributes=(attrs)
    attrs.each do |a|
      if a[:award_id].present? && a[:award_id] != "add"
        if a[:id].present?
          BookAward.find(a[:id]).update_attributes(a)
        else
          a.delete :id
          book_awards.build(a)
        end
      else
        BookAward.find(a[:id]).destroy if a[:id].present?
      end
    end
  end
  
  def description_attributes=(attrs)
    attrs.each do |a|
      if a[:title].present?
        if a[:id].present?
          Description.find(a[:id]).update_attributes(a)
        else
          a.delete :id
          descriptions.build(a)
        end
      else
        Description.find(a[:id]).destroy if a[:id].present?
      end
    end
  end
  
  def cover_image_id
    cover_image.present? ? cover_image.id : nil
  end
  
  def cover_image_id=(cover_id)
    if cover_id.present?
      self.cover_image = CoverImage.find(cover_id)
    end
  end
  
  def cover_image_url=(url)
    if (cover_image.present?)
      cover_image.destroy
    end
    
    self.cover_image = CoverImage.create(:remote_filename_url => url)
  end
  
  def number_of_copies
    new_copies.stocked.inject(0) { |num, x| num + x.stock } + used_copies.stocked.length
  end
  
  def check_stock
    self.in_stock = copies.stocked.length > 0
    save
  end

  def used_copy_min_price
    price = used_copies.stocked.map{|x| x.price}.min.to_i
    return price > 0 ? price : nil
  end
  
  def new_copy_min_price
    price = new_copies.stocked.map{|x| x.price}.min.to_i
    return price > 0 ? price : nil
  end
  
  def next_book
    Book.where('"books"."created_at" > ?', created_at).order(:created_at).limit(1).first || Book.limit(1).order(:created_at).first
  end
  
  def previous_book
    Book.where('"books"."created_at" < ?', created_at).order('"books"."created_at" DESC').limit(1).first || Book.limit(1).order('"books"."created_at" DESC').first
  end
  
  # Function to return a scope sorted by a parameter
  def self.sort_by_param(sort, sort_order)
    sort_order = sort_order.present? ? " DESC" : ""
    case sort
    when "random"
      order("random()#{sort_order}")
    when "title"
      order("books.title#{sort_order}")
    when "author"
      order("auth.last_name#{sort_order}, auth.first_name#{sort_order}")
    when "age"
      order("age_from#{sort_order}")
    when "price"
      joins("LEFT JOIN editions AS ed ON ed.product_id = products.id LEFT JOIN copies AS cop ON (cop.edition_id = ed.id AND cop.in_stock = TRUE)").group(columns_list).order("MIN(cop.price)#{sort_order}")
    when "date"
      sort_order = sort_order.present? ? "" : " DESC"
      order("books.book_date#{sort_order}")
    else
      order("books.book_date#{sort_order}")
    end
  end
end
