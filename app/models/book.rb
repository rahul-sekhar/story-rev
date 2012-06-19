class Book < ActiveRecord::Base
  attr_accessible :title, :author_name, :illustrator_name, :publisher_name, :year, :country_name, :age_from, :age_to,
                  :collection_list, :amazon_url, :short_description, :book_type_id,
                  :award_attributes, :description_attributes, :cover_image_id, :cover_image_url
  
  after_initialize :init
  before_validation :set_accession_id
  after_validation :validate_virtual_attributes
  before_save :check_age_level
  after_create :set_book_date
  
  has_and_belongs_to_many :collections, :join_table => :books_collections, :uniq => true
  belongs_to :author
  belongs_to :illustrator
  belongs_to :publisher
  belongs_to :book_type
  belongs_to :country
  has_many :book_awards, :dependent => :destroy
  has_many :editions, :dependent => :destroy
  has_many :copies, :through => :editions
  has_many :descriptions, :dependent => :destroy
  has_one :cover_image, :dependent => :destroy
  
  validates :title, :presence => true, :length => { :maximum => 255 }, :uniqueness => true
  validates :author, :presence => true
  validates :age_from, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0, :less_than => 100 }, :allow_blank => true
  validates :age_to, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0, :less_than => 100 }, :allow_blank => true
  validates :year, :numericality => { :only_integer => true, :greater_than => 1000, :less_than => 2100 }, :allow_blank => true
  validates :amazon_url, :length => { :maximum => 200 }
  validates :accession_id, :presence => true, :uniqueness => true, :numericality => { :only_integer => true }
  
  validates_associated :author
  validates_associated :illustrator
  validates_associated :publisher
  validates_associated :country
  validates_associated :book_awards
  validates_associated :descriptions
  
  scope :stocked, where(:in_stock => true)
  
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
  
  def author_name=(name)
    self.author = name.present? ? (Author.name_is(name) || Author.new({ :full_name => name })) : nil
  end
  
  def author_name
    author ? author.full_name : nil
  end
  
  def illustrator_name=(name)
    self.illustrator = name.present? ? (Illustrator.name_is(name) || Illustrator.new({ :full_name => name })) : nil
  end
  
  def illustrator_name
    illustrator ? illustrator.full_name : nil
  end
  
  def publisher_name=(name)
    self.publisher = name.present? ? (Publisher.name_is(name).first || Publisher.new({ :name => name })) : nil
  end
  
  def publisher_name
    publisher ? publisher.name : nil
  end
  
  def country_name=(name)
    self.country = name.present? ? (Country.name_is(name).first || Country.new({ :name => name })) : nil
  end
  
  def country_name
    country ? country.name : nil
  end
  
  def collection_list
    collections.map{ |x| x.name }.join(", ")
  end
  def collection_list=(tag_list)
    self.collections = Collection.split_list(tag_list)
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
    if (cover_image.present? && cover_id.to_i != cover_image.id)
      cover_image.destroy
    end
    
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
    copies.stocked.inject(0) { |num, x| num + x.stock }
  end
  
  def check_stock
    self.in_stock = copies.stocked.length > 0
    save
  end
  
  def in_collection? (collection)
    collection.book_ids.include?(id)
  end
  
  def next_book
    Book.where('"books"."created_at" > ?', created_at).order(:created_at).limit(1).first || Book.limit(1).order(:created_at).first
  end
  
  def previous_book
    Book.where('"books"."created_at" < ?', created_at).order('"books"."created_at" DESC').limit(1).first || Book.limit(1).order('"books"."created_at" DESC').first
  end
  
  def used_copy_min_price
    price = copies.stocked.select{|x| x.new_copy == false}.map{|x| x.price}.min.to_i
    return price > 0 ? price : nil
  end
  
  def new_copy_min_price
    price = copies.stocked.select{|x| x.new_copy == true}.map{|x| x.price}.min.to_i
    return price > 0 ? price : nil
  end
  
  # Function to search by title, accession ID or author
  def self.search(query, fields, output)
    escaped = SqlHelper::escapeWildcards(query).upcase
    book_array = []
    if fields == "all" && output == "display_target"
      book_array |= self.select("id, title, in_stock")
                            .where("UPPER(title) LIKE ?", "%#{escaped}%")
                            .map { |x| {:id => x.id, :name => x.title }}
      
      if (escaped =~ /^[0-9]/)
        book_array |= self.select("id, title, accession_id, in_stock")
                              .where('accession_id LIKE ?', "#{escaped}%")
                              .map { |x| {:id => x.id, :name => "#{x.title} - #{x.accession_id}" }}
      else
        book_array |= self.includes(:author)
                            .where('UPPER("authors".first_name || \' \' || "authors".last_name) LIKE ?', "%#{escaped}%")
                            .map { |x| {:id => x.id, :name => "#{x.title} - #{x.author.full_name}" }}
      end
    end
    return book_array
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
      joins("LEFT JOIN editions AS ed ON ed.book_id = books.id LEFT JOIN copies AS cop ON cop.edition_id = ed.id").group(columns_list).order("MIN(cop.price)#{sort_order}")
    when "date"
      sort_order = sort_order.present? ? "" : " DESC"
      order("books.book_date#{sort_order}")
    else
      order("books.book_date#{sort_order}")
    end
  end
  
  # Function to return a filtered scope, depending on the parameters
  def self.filter(p)
    filtered = self.scoped
    filtered_copies = false
    editions = Edition.unscoped
    copies = Copy.unscoped.stocked
    
    if p[:recent].present?
      new_books = Book.unscoped.select("books.id, books.in_stock, MAX(e.created_at) as ed_date")
          .joins("INNER JOIN editions AS e ON e.book_id = books.id INNER JOIN copies as c ON c.edition_id = e.id WHERE c.in_stock = TRUE")
          .group("books.id, books.in_stock").order("ed_date DESC").limit(28)
      filtered = filtered.where("books.id IN (?)", new_books.map{ |x| x.id })
    end
    
    if p[:award_winning].present?
      filtered = filtered.where("books.id IN (?)", BookAward.all.map{ |x| x.book_id })
    end
    
    if p[:search].present?
      sqlSearch = "%#{SqlHelper::escapeWildcards(p[:search].downcase)}%"
      filtered = filtered
        .joins('LEFT JOIN illustrators AS ill ON ill.id = books.illustrator_id')
        .where('LOWER(books.title) LIKE ? OR
               LOWER(auth.first_name || \' \' || auth.last_name) LIKE ? OR
               LOWER(ill.first_name || \' \' || ill.last_name) LIKE ?',
               sqlSearch, sqlSearch, sqlSearch)
    end
    
    if p[:collection].present?
      filtered = filtered.where('books.id IN (SELECT book_id FROM books_collections WHERE collection_id = ?)', p[:collection].to_i)
    end
    
    if p[:publisher].present?
      filtered_copies = true
      editions = editions.joins(:book).where("books.publisher_id = ?", p[:publisher].to_i)
    end
    
    if p[:award].present?
      awards = Award.where(:award_type_id => p[:award].to_i)
      book_awards = BookAward.where(:award_id => awards.map{ |x| x.id })
      filtered = filtered.where("books.id IN (?)", book_awards.map{ |x| x.book_id })
    end
    
    if p[:author].present?
      filtered = filtered.where(:author_id => p[:author].to_i)
    end
    
    if p[:illustrator].present?
      filtered = filtered.where(:illustrator_id => p[:illustrator].to_i)
    end
    
    if p[:age].present?
      age = p[:age].to_i
      filtered = filtered.where("age_from <= ? AND age_to >= ? OR (age_from IS NULL AND age_to = ?) OR (age_to IS NULL AND age_from = ?)", age, age, age, age)
    end
    
    if p[:type].present?
      filtered_copies = true
      copies = copies.where(:new_copy => p[:type] == "new")
    end
    
    if p[:condition].present?
      filtered_copies = true
      copies = copies.where("condition_rating >= ?", p[:condition].to_i)
    end
    
    price_from = nil
    price_to = nil
    
    if p[:price_from].present?
      price_from = p[:price_from].to_i
    end
    if p[:price_to].present?
      price_to = p[:price_to].to_i
    end
    
    if p[:price].present? && p[:price_from].blank? && p[:price_to].blank?
      a = p[:price].split("-").map{|x| x.to_i}
      if a.length == 2
        price_from = a.min
        price_to = a.max
      else
        price_from = a[0]
      end
    end
  
    if price_from || price_to
      filtered_copies = true
      
      if price_to.to_i > 0
        copies = copies.where("price BETWEEN ? AND ?", price_from.to_i, price_to.to_i)
      else
        copies = copies.where("price > ?", price_from.to_i)
      end
    end
    
    if p[:format].present?
      filtered_copies = true
      editions = editions.where(:format_id => p[:format].to_i)
    end
    
    if p[:category].present?
      filtered = filtered.where(:book_type_id => p[:category].to_i)
    end
    
    if filtered_copies
      editions = editions.where("editions.id IN (?)", copies.map {|c| c.edition_id })
      filtered = filtered.where("books.id IN (?)", editions.map { |e| e.book_id })
    end
    
    return filtered
  end
end
