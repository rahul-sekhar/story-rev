class NewCopy < ActiveRecord::Base
  include CopyBase
  
  before_validation :set_accession_id
  after_initialize :init
  after_save :check_product_stock
  after_destroy :check_product_stock
  
  belongs_to :edition
  
  validates :accession_id, :presence => true, :uniqueness => true
  validates :price, :numericality => { :only_integer => true }
  validates :number, :numericality => { :only_integer => true }
  
  scope :stocked, where('number > 0 OR limited_copies = FALSE')
  scope :unstocked, where('number <= 0 AND limited_copies = TRUE')
  
  def init
    self.limited_copies = true if limited_copies.nil?
  end 
  
  def get_hash
    return {
      :id => id,
      :accession_id => accession_id,
      :price => price,
      :formatted_price => formatted_price,
      :limited_copies => limited_copies,
      :number => number
    }
  end
end
