class Description < ActiveRecord::Base
  attr_accessible :title, :content

  default_scope :order => "created_at ASC"
  belongs_to :book
  
  validates :title, length: { maximum: 255 }, presence: true
end
