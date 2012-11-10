class Book < ActiveRecord::Base
  extend NameTags

  default_scope -> { includes(:author) }

  attr_accessible :title, :author_name, :illustrator_name, :publisher_name, 
  :year, :country_name, :age_from, :age_to, :collection_list, :amazon_url, 
  :short_description, :book_type_id, :award_attributes, 
  :description_attributes, :cover_image_id, :cover_image_url
  
  after_validation :validate_virtual_attributes
  before_save :check_age_level
  before_validation :set_accession_id
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
      greater_than: 0 
    }

  validates :in_stock, inclusion: {in: [true, false]}
  
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
    new_copies.select{|c| c.stock > 0}.inject(0){|num, x| num + x.stock} + 
    used_copies.select{|c| c.stock > 0}.length
  end
  
  def check_stock
    self.in_stock = copies.select{|c| c.stock > 0}.length > 0
    save
  end

  def used_copy_min_price
    price = used_copies.select{|c| c.stock > 0}.map{|x| x.price}.min.to_i
    return price > 0 ? price : nil
  end
  
  def new_copy_min_price
    price = new_copies.select{|c| c.stock > 0}.map{|x| x.price}.min.to_i
    return price > 0 ? price : nil
  end
  
  def next_book
    Book.where('"books"."created_at" > ?', created_at).order(:created_at).limit(1).first || Book.limit(1).order(:created_at).first
  end
  
  def previous_book
    Book.where('"books"."created_at" < ?', created_at).order('"books"."created_at" DESC').limit(1).first || Book.limit(1).order('"books"."created_at" DESC').first
  end
  
  # Book sorting scope
  def self.sort(by, desc = nil)
    dir = desc.present? ? "desc" : "asc"
    
    case by
    when "random"
      order{random.func}
    when "title"
      order{title.send(dir)}
    when "author"
      joins{author}.order{[author.last_name.send(dir), author.first_name.send(dir)]}
    when "age"
      order{[(age_from == nil), age_from.send(dir)]}
    when "price"
      joins{editions.copies}.where{editions.copies.stock > 0}.group{id}.order{min(editions.copies.price).send(dir)}
    else
      # Default to order by date, reverse direction for this
      dir = desc.present? ? "asc" : "desc"
      order{book_date.send(dir)}
    end
  end

  # Sets the seed for the database random function - val should be between 0 and 1
  def self.set_seed(val)
    connection.execute("select setseed(#{val.to_f})")
  end

  # Filter books, using the BookFilter class
  def self.filter(params)
    BookFilter.new(params).filter
  end
end
