class Award < ActiveRecord::Base
  attr_accessible :award_type_id, :name
  
  default_scope :include => :award_type
  belongs_to :award_type
  has_many :book_awards, :dependent => :destroy
  
  validates :name, 
    length: { maximum: 150 },
    presence: true,
    uniqueness: { case_sensitive: false, scope: :award_type_id }
  
  def full_name
    if (name == "-")
      award_type.name
    else
      "#{award_type.name} #{name}"
    end
  end
end
