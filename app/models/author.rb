class Author < ActiveRecord::Base
  include Person
  
  attr_writer :full_name
  
  before_validation :convert_full_name, :set_accession_id
  
  has_many :products, :dependent => :destroy
  
  validates :full_name, :length => { :maximum => 150 }, :presence => true
  validates :accession_id, :presence => true, :uniqueness => true
  
  def set_accession_id
    self.accession_id = find_accession_id
  end
  
  def find_accession_id
    if last_name.present?
      letter = last_name[0].upcase
      return accession_id if accession_id.to_s[0] == letter
      
      last_author = Author.where('accession_id LIKE ?', "#{letter}%").order("accession_id DESC").first
      if last_author.present?
        new_acc = last_author.accession_id[2,3].to_i + 1
        "#{letter}-#{"%03d" % new_acc}"
      else
        "#{letter}-001"
      end
    end
  end
end
