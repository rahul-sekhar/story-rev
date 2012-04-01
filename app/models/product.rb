class Product < ActiveRecord::Base
  default_scope :include => :author
  attr_accessible :title, :author_name, :illustrator_name, :publisher_name, :year, :country_name, :age_from, :age_to,
                  :collection_list, :flipkart_id, :amazon_url, :short_description, :product_type_id, :content_type_id,
                  :award_attributes, :other_field_attributes, :cover_image_id, :cover_image_url, :language_id
  
  after_initialize :init
  before_validation :set_accession_id
  after_validation :validate_virtual_attributes
  before_save :check_age_level
  after_create :set_timestamps
  
  has_and_belongs_to_many :collections, :join_table => :products_collections, :uniq => true
  belongs_to :author
  belongs_to :illustrator
  belongs_to :publisher
  belongs_to :language
  belongs_to :product_type
  belongs_to :content_type
  belongs_to :country
  has_many :product_awards, :dependent => :destroy
  has_many :editions, :dependent => :destroy
  has_many :copies, :through => :editions
  has_many :other_fields, :dependent => :destroy
  has_one :cover_image, :dependent => :destroy
  
  validates :title, :presence => true, :length => { :maximum => 255 }, :uniqueness => true
  validates :author, :presence => true
  validates :content_type, :presence => true
  validates :language, :presence => true
  validates :age_from, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0, :less_than => 100 }, :allow_blank => true
  validates :age_to, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0, :less_than => 100 }, :allow_blank => true
  validates :year, :numericality => { :only_integer => true, :greater_than => 1000, :less_than => 2100 }, :allow_blank => true
  validates :flipkart_id, :length => { :maximum => 40 }
  validates :amazon_url, :length => { :maximum => 200 }
  validates :accession_id, :presence => true, :uniqueness => true, :numericality => { :only_integer => true }
  
  validates_associated :author
  validates_associated :illustrator
  validates_associated :publisher
  validates_associated :country
  validates_associated :product_awards
  validates_associated :other_fields
  
  scope :stocked, where(:in_stock => true)
  
  def self.includes_cover
    includes(:cover_image)
  end
  
  def self.includes_data
    includes(:illustrator, :publisher, :collections, :copies, :product_type, :content_type, :language, :country, :other_fields, { :product_awards => { :award => :award_type }}, :editions => [:format, :publisher])
  end
  
  def self.includes_copies
    includes({:editions => [:format, :publisher]}, :copies)
  end
  
  def self.sort_by_param(sort)
    case sort
    when "random"
      order("random()")
    when "date"
      order('"products"."book_date"')
    when "title"
      order(:title)
    when "author"
      order('"auth"."last_name", "auth"."first_name"')
    when "age"
      order("age_from")
    when "price"
      joins("LEFT JOIN editions AS ed ON ed.product_id = products.id LEFT JOIN copies AS cop ON cop.edition_id = ed.id").group("products.id").order("MIN(cop.price)")
    else
      self.scoped
    end
  end
  
  def self.filter(p)
    filtered = self.scoped
    filtered_copies = false
    editions = Edition.scoped
    copies = Copy.stocked
    
    if p[:search].present?
      sqlSearch = "%#{SqlHelper::escapeWildcards(p[:search].downcase)}%"
      filtered = filtered
        .joins('LEFT JOIN illustrators AS ill ON ill.id = products.illustrator_id')
        .where('LOWER(products.title) LIKE ? OR
               LOWER(auth.first_name || \' \' || auth.last_name) LIKE ? OR
               LOWER(ill.first_name || \' \' || ill.last_name) LIKE ?',
               sqlSearch, sqlSearch, sqlSearch)
    end
    
    if p[:age_from].present? && p[:age_from].to_i > 0
      filtered = filtered.where("age_from > ?", p[:age_from].to_i)
    end
    
    if p[:age_to].present? && p[:age_to].to_i > 0
      filtered = filtered.where("age_to < ?", p[:age_to].to_i)
    end
    
    if p[:type].is_a?(Hash) && p[:type][:new] != p[:type][:used]
      filtered_copies = true
      copies = copies.where(:new_copy => !!p[:type][:new])
    end
    
    if p[:condition].is_a?(Hash)
      filtered_copies = true
      copies = copies.where(:condition_rating => p[:condition].keys)
    end
    
    price_conditions = []
    data_array = []
    
    if p[:price].is_a?(Hash)
      p[:price].keys.each do |range|
        a = range.split("-").map{|x| x.to_i}
        if a.length == 2
          price_conditions << "price BETWEEN ? AND ?"
          data_array << a.min
          data_array << a.max
        else
          price_conditions << "price > ?"
          data_array << a[0]
        end
      end
    end
      
    from = p[:price_from].to_i
    to = p[:price_to].to_i
    
    if from > 0 && to > 0
      price_conditions << "price BETWEEN ? AND ?"
      data_array << from
      data_array << to
    elsif from > 0
      price_conditions << "price > ?"
      data_array << from
    elsif to > 0
      price_conditions << "price < ?"
      data_array << to
    end
    
    if price_conditions.present?
      filtered_copies = true
      copies = copies.where(price_conditions.join(" OR "), *data_array)
    end
    
    if p[:format].is_a?(Hash)
      filtered_copies = true
      editions = editions.where(:format_id => p[:format].keys)
    end
    
    if p[:content_type].is_a?(Hash) && p[:content_type].length == 1
      filtered = filtered.where(:content_type_id => [p[:content_type].keys.first, 3])
    end
    
    if p[:book_type].is_a?(Hash)
      filtered = filtered.where(:product_type_id => p[:book_type].keys)
    end
    
    if p[:collection].present?
      filtered = filtered.where('"products"."id" IN (SELECT "product_id" FROM "products_collections" WHERE "collection_id" = ?)', p[:collection])
    end
    
    if p[:publisher].present?
      filtered_copies = true
      editions = editions.joins(:product).where("editions.publisher_id = ? OR products.publisher_id = ?", p[:publisher], p[:publisher])
    end
    
    if p[:award].present?
      filtered = filtered.where(:id => ProductAward.where(:award_id => p[:award]).map {|x| x.product_id})
    end
    
    if p[:author].present?
      filtered = filtered.where(:author_id => p[:author])
    end
    
    if p[:illustrator].present?
      filtered = filtered.where(:illustrator_id => p[:illustrator])
    end
    
    if filtered_copies
      editions = editions.where(:id => copies.map {|c| c.edition_id })
      filtered = filtered.where(:id => editions.map { |e| e.product_id })
    end
    
    return filtered
  end
  
  def self.search(query, fields, output)
    escaped = SqlHelper::escapeWildcards(query).upcase
    product_array = []
    if fields == "all" && output == "display_target"
      product_array |= self.select("id, title, in_stock, content_type_id, language_id")
                            .where("UPPER(title) LIKE ?", "%#{escaped}%")
                            .map { |x| {:id => x.id, :name => x.title }}
      
      if (escaped =~ /^[A-Z]-[0-9]/)
        product_array |= self.select("id, title, accession_id, in_stock, content_type_id, language_id")
                              .where('accession_id LIKE ?', "#{escaped}%")
                              .map { |x| {:id => x.id, :name => "#{x.title} - #{x.accession_id}" }}
      elsif (escaped =~ /^[0-9]+$/)
      else
        product_array |= self.includes(:author)
                            .where('UPPER("authors".first_name || \' \' || "authors".last_name) LIKE ?', "%#{escaped}%")
                            .map { |x| {:id => x.id, :name => "#{x.title} - #{x.author.full_name}" }}
      end
    end
    return product_array
  end
  
  def init
    self.in_stock = false if in_stock.nil?
    self.content_type_id ||= 1
    self.language_id ||= 1
  end
  
  def set_timestamps
    touch :book_date
    touch :out_of_stock_at
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
    last_product = Product.where("accession_id IS NOT NULL").order("accession_id DESC").limit(1).first
    return last_product.present? ? last_product.accession_id.to_i + 1 : 1
  end
  
  def build_empty_fields
    if product_awards.length == 0
      self.product_awards.build
    end
    
    if other_fields.length == 0
      self.other_fields.build
    end
  end
  
  def age_level
    if (age_from && age_to)
      if (age_from == age_to)
        "#{age_from}"
      else
        "#{age_from} - #{age_to}".html_safe
      end
    elsif age_from
      "#{age_from}+"
    elsif age_to
      "#{age_to}-"
    else
      ""
    end
  end
  
  def creators
    "#{author_name}#{illustrator.present? && illustrator_name != author_name ? " and #{illustrator_name}" : ""}"
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
  
  def award_list
    product_awards.map {|x| x.full_name}.join(", ")
  end
  
  def editions_json
    editions.to_json({ :only => [:id, :isbn, :format_name, :base_price] })
  end
  
  def award_attributes=(attrs)
    attrs.each do |a|
      if a[:award_id].present? && a[:award_id] != "add"
        if a[:id].present?
          ProductAward.find(a[:id]).update_attributes(a)
        else
          a.delete :id
          product_awards.build(a)
        end
      else
        ProductAward.find(a[:id]).destroy if a[:id].present?
      end
    end
  end
  
  def other_field_attributes=(attrs)
    attrs.each do |a|
      if a[:title].present?
        if a[:id].present?
          OtherField.find(a[:id]).update_attributes(a)
        else
          a.delete :id
          other_fields.build(a)
        end
      else
        OtherField.find(a[:id]).destroy if a[:id].present?
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
  
  def get_collection_hash
    {
      :id => id,
      :title => title,
      :author_name => author_name,
      :age_level => age_level,
      :stock => number_of_copies
    }
  end
  
  def get_list_hash
    {
      :id => id,
      :title => title,
      :author_name => author_name,
      :author_last_name => author.last_name,
      :illustrator_name => illustrator_name,
      :illustrator_last_name => illustrator.present? ? illustrator.last_name : nil,
      :age_level => age_level,
      :age_from => age_from,
      :collection_list => collection_list,
      :award_list => award_list,
      :stock => number_of_copies
    }
  end
  
  def number_of_copy_types
    copies.stocked.length
  end
  
  def number_of_copies
    copies.stocked.used_copies.length + copies.stocked.new_copies.map {|x| x.number}.inject(:+).to_i
  end
  
  def check_stock
    is_in_stock = copies.stocked.length > 0
    
    if (in_stock != is_in_stock)
        self.in_stock = is_in_stock
        
        if (is_in_stock)
          touch :in_stock_at
          
          # If the product went out of stock at least a day ago, update the book_date
          touch :book_date if ((in_stock_at - out_of_stock_at) / 3600) > 24
          
        else
          touch :out_of_stock_at
        end
        
        save
    end
  end
  
  def in_collection? (collection)
    collection.product_ids.include?(id)
  end
  
  def next_product
    Product.where('"products"."created_at" > ?', created_at).order(:created_at).limit(1).first || Product.limit(1).order(:created_at).first
  end
  
  def previous_product
    Product.where('"products"."created_at" < ?', created_at).order('"products"."created_at" DESC').limit(1).first || Product.limit(1).order('"products"."created_at" DESC').first
  end
  
  def used_copy_min_price
    price = copies.select{|x| x.new_copy == false}.map{|x| x.price}.min.to_i
    return price > 0 ? RupeeHelper.to_rupee(price) : nil
  end
  
  def new_copy_min_price
    price = copies.select{|x| x.new_copy == true}.map{|x| x.price}.min.to_i
    return price > 0 ? RupeeHelper.to_rupee(price) : nil
  end
end
