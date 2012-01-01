class Product < ActiveRecord::Base
  attr_accessible :title, :author_name, :illustrator_name, :publisher_name, :year, :age_from, :age_to,
                  :genre_list, :keyword_list, :flipkart_id, :amazon_url, :short_description,
                  :award_attributes, :other_field_attributes
  
  before_validation :set_accession_id
  
  has_and_belongs_to_many :keywords, :join_table => :products_keywords, :uniq => true
  has_and_belongs_to_many :genres, :join_table => :products_genres, :uniq => true
  has_and_belongs_to_many :product_tags, :join_table => :products_product_tags, :uniq => true
  belongs_to :author
  belongs_to :illustrator
  belongs_to :publisher
  has_many :product_awards, :dependent => :destroy
  has_many :editions, :dependent => :destroy
  has_many :copies, :through => :editions
  has_many :other_fields, :dependent => :destroy
  
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
  validates_associated :publisher
  validates_associated :product_awards
  validates_associated :other_fields
  
  def set_accession_id
    self.accession_id = find_accession_id
  end
  
  def find_accession_id
    if title.present?
      letter = title[0].upcase
      num = self.class.where('UPPER(LEFT(title,1)) = ? AND id <> ?', letter, id).count + 1
      return "#{letter}#{"%03d" % num}"
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
  
  def author_name=(name)
    self.author = name.present? ? (Author.name_is(name) || Author.new({ :full_name => name })) : nil
  end
  
  def author_name
    author ? author.full_name : ""
  end
  
  def illustrator_name=(name)
    self.illustrator = name.present? ? (Illustrator.name_is(name) || Illustrator.new({ :full_name => name })) : nil
  end
  
  def illustrator_name
    illustrator ? illustrator.full_name : ""
  end
  
  def publisher_name=(name)
    self.publisher = name.present? ? (Publisher.where(:name => name).first || Publisher.new({ :name => name })) : nil
  end
  
  def publisher_name
    publisher ? publisher.name : ""
  end
  
  def genre_list
    genres.map{ |x| x.name }.join(",")
  end
  
  def genre_list=(tag_list)
    self.genres = Genre.split_list(tag_list)
  end
  
  def keyword_list
    keywords.map{ |x| x.name }.join(",")
  end
  
  def keyword_list=(tag_list)
    self.keywords = Keyword.split_list(tag_list)
  end
  
  def award_attributes=(attrs)
    attrs.each do |a|
      logger.info a.inspect
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
end
