class Award < ActiveRecord::Base
  default_scope :include => :award_type
  belongs_to :award_type
  has_many :book_awards, :dependent => :destroy
  
  validates :name, :length => { :maximum => 150 }, :presence => true
  
  def full_name
    if (name == "-")
      award_type.name
    else
      "#{award_type.name} #{name}"
    end
  end
end
