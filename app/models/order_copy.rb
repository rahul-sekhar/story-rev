class OrderCopy < ActiveRecord::Base
  self.table_name = :orders_copies

  default_scope -> { includes{copy} }
  
  attr_accessible :copy_id, :number
  
  belongs_to :order
  belongs_to :copy, readonly: true
  belongs_to :new_copy, foreign_key: :copy_id
  belongs_to :used_copy, foreign_key: :copy_id

  validates :copy, presence: true
  validates :number, 
    numericality: { only_integer: true, greater_than: 0}
  validates :ticked, inclusion: { in: [true, false] }

  scope :stocked, -> { joins{copy}.where{copy.stock > 0} }
  scope :unstocked, -> { joins{copy}.where{copy.stock <= 0} }
  
  def number=(val)
    write_attribute(:number, val.to_i) if copy.new_copy && val.to_i > 0
  end

  def price
    copy.price * number
  end
  
  def get_hash
    {
      :id => id,
      :title => copy.book.title,
      :author_name => copy.book.author_name,
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
end
