class Copy < ActiveRecord::Base
  before_validation :set_accession_id
  
  belongs_to :edition
  validates :accession_id, :presence => true, :uniqueness => true
  validates :condition_rating, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 5 }
  validates :price, :numericality => { :only_integer => true }
  
  def formatted_price
    RupeeHelper::to_rupee(price)
  end
  
  def get_hash
    return {
      :id => id,
      :accession_id => accession_id,
      :price => price,
      :formatted_price => formatted_price,
      :condition_description => condition_description,
      :condition_rating => condition_rating
    }
  end
  
  def set_accession_id
    self.accession_id = find_accession_id
  end
  
  def find_accession_id
    base_acc = edition.product.accession_id
    last_copy = edition.product.copies.where('"copies".id <> ?', id || 0).order("accession_id DESC").first
    if last_copy.present?
      new_acc = last_copy.accession_id[7,9].to_i + 1
      "#{base_acc}-#{"%03d" % new_acc}"
    else
      "#{base_acc}-001"
    end
  end
end
