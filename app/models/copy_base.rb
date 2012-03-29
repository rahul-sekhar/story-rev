module CopyBase
  
  def set_accession_id
    self.accession_id = find_accession_id
  end
  
  def find_accession_id
    base_acc = product.accession_id
    return accession_id if accession_id.to_s[0,9] == base_acc
    
    last_new_copy = NewCopy.where('accession_id LIKE ?', "#{base_acc}%").order("accession_id DESC").first
    new_acc = last_new_copy.accession_id[10,3].to_i if last_new_copy.present?
    last_copy = Copy.where('accession_id LIKE ?', "#{base_acc}%").order("accession_id DESC").first
    new_acc = [new_acc || 0, last_copy.accession_id[10,3].to_i].max if last_copy.present?
    
    if new_acc
      new_acc += 1
      "#{base_acc}-#{"%03d" % new_acc}"
    else
      "#{base_acc}-001"
    end
  end
  
  def product
    edition.product
  end
  
  def check_product_stock
    product.check_stock
  end
  
  def formatted_price
    RupeeHelper::to_rupee(price)
  end
  
  module ClassMethods
  end
  
  def self.included(base)
    base.extend ClassMethods
  end
end
