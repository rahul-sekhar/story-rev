class OrderCopy < ActiveRecord::Base
  self.table_name = :orders_copies
  
  after_initialize :init
  before_save :check_number
  
  belongs_to :order
  belongs_to :copy
  
  scope :stocked, where(:copies => { :in_stock => true })
  scope :unstocked, where(:copies => { :in_stock => false })
  
  def init
    self.number ||= 1
    self.ticked = false if ticked.nil?
  end
  
  def price
    copy.price * number
  end
  
  def check_number
    self.number = 1 unless (copy.new_copy && number > 0)
  end
  
  def get_hash
    {
      :id => id,
      :title => copy.product.title,
      :author_name => copy.product.author_name,
      :accession_id => copy.accession_id,
      :price => copy.formatted_price,
      :format_name => copy.edition.format_name,
      :isbn => copy.edition.isbn,
      :new_copy => copy.new_copy,
      :condition_rating => copy.new_copy ?  nil : copy.condition_rating,
      :condition_description => copy.new_copy ? copy.condition_description : nil,
      :number => copy.new_copy ? number : nil,
      :ticked => ticked
    }
  end
  
  def set_number=(num)
    self.copy.number -= (num.to_i - number)
    self.copy.save
    self.number = num.to_i
  end
  
  def revert_copy
    if copy.new_copy
      copy.number += number
      copy.save
    else
      copy.set_stock = true
    end
    
    self.copy = nil
  end
end
