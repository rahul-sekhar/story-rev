class Product < ActiveRecord::Base
  default_scope includes(:author)
  
  attr_accessible :title, :author_name, :illustrator_name, :year, :age_from, :age_to,
                  :keyword_list, :flipkart_id, :amazon_url, :short_description,
                  :award_attributes, :other_field_attributes, :cover_image_id, :cover_image_url
  
  before_validation :set_accession_id
  after_validation :validate_virtual_attributes
  
  has_and_belongs_to_many :keywords, :join_table => :products_keywords, :uniq => true
  has_and_belongs_to_many :product_tags, :join_table => :products_product_tags, :uniq => true
  belongs_to :author
  belongs_to :illustrator
  has_many :product_awards, :dependent => :destroy
  has_many :editions, :dependent => :destroy
  has_many :copies, :through => :editions
  has_many :other_fields, :dependent => :destroy
  has_one :cover_image, :dependent => :destroy
  
  validates :title, :presence => true, :length => { :maximum => 250 }, :uniqueness => true
  validates :author, :presence => true
  validates :age_from, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0, :less_than => 100 }, :allow_blank => true
  validates :age_to, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0, :less_than => 100 }, :allow_blank => true
  validates :year, :numericality => { :only_integer => true, :greater_than => 1000, :less_than => 2100 }, :allow_blank => true
  validates :flipkart_id, :length => { :maximum => 40 }
  validates :amazon_url, :length => { :maximum => 200 }
  validates :accession_id, :presence => true, :uniqueness => true
  
  validates_associated :author
  validates_associated :illustrator
  
  validates_associated :product_awards
  validates_associated :other_fields
  
  scope :stocked, where(:in_stock => true)
  
  def self.includes_data
    includes(:illustrator, :keywords, :product_tags, :other_fields, { :product_awards => { :award => :award_type }})
  end
  
  def self.includes_copies
    includes(:editions => [:format, :copies])
  end
  
  def self.search(query, fields, output)
    escaped = SqlHelper::escapeWildcards(query).upcase
    product_array = []
    if fields == "all" && output == "display_target"
      product_array |= self.select("id, title")
                            .where("UPPER(title) LIKE ?", "%#{escaped}%")
                            .map { |x| {:id => x.id, :name => x.title }}
      
      if (escaped =~ /^[A-Z]-[0-9]/)
        product_array |= self.select("id, title, accession_id")
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
  
  def validate_virtual_attributes
    self.errors[:author_name] = errors[:author] if errors[:author].present?
    self.errors[:illustrator_name] = errors[:illustrator] if errors[:illustrator].present?
  end
  
  def set_accession_id
    self.accession_id = find_accession_id
  end
  
  def find_accession_id
    if author.present? && author.has_name?
      letter = author.get_letter.upcase
      return accession_id if accession_id.to_s[0] == letter
      
      last_product = Product.where('accession_id LIKE ?', "#{letter}%").order("accession_id DESC").first
      if last_product.present?
        new_acc = last_product.accession_id[2,4].to_i + 1
        "#{letter}-#{"%03d" % new_acc}"
      else
        "#{letter}-001"
      end
    end
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
      "#{age_from}-#{age_to}"
    elsif age_from
      "#{age_from}+"
    elsif age_to
      "#{age_to}-"
    else
      ""
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
  
  def keyword_list
    keywords.map{ |x| x.name }.join(",")
  end
  def keyword_list=(tag_list)
    self.keywords = Keyword.split_list(tag_list)
  end
  def keywords_json
    keywords.to_json({ :only => [:id, :name] })
  end
  
  def product_tag_list
    product_tags.map{ |x| x.name }.join(",")
  end
  def product_tag_list=(tag_list)
    self.product_tags = product_tag.split_list(tag_list)
  end
  def product_tags_json
    product_tags.to_json({ :only => [:id, :name] })
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
    
    self.cover_image = CoverImage.new(:remote_filename_url => url)
  end
  
  def get_theme_hash
    {
      :id => id,
      :title => title,
      :author_name => author_name,
      :age_level => age_level,
      :in_stock => in_stock
    }
  end
  
  def check_stock
    is_in_stock = (copies.stocked.length > 0)
    if (in_stock != is_in_stock)
        self.in_stock = is_in_stock
        save
    end
  end
  
  def self.sort_accession_ids
    p_hash = {}
    Product.order(:accession_id).each do |p|
      p_hash[p.accession_id] = p.title
    end
    
    p_hash.each do |k,v|
      puts "#{k} - #{v}"
    end
  end
  
  # Functions for debugging and administration via the console
  def self.reset_accession_ids
    i = 0
    
    Product.all.each do |p|
      i+=1
      p.accession_id = "#{i.to_s}#{p.accession_id}"
      p.save(:validate => false)
    end
    
    Product.all.each do |p|
      p.save  
    end
    
    return nil
  end
  
  def self.display_by_accession_id
    Product.order(:accession_id).each do |p|
      puts "#{p.accession_id} - #{p.author.last_name}, #{p.author.first_name} - #{p.title}"
    end
    return nil
  end
end
