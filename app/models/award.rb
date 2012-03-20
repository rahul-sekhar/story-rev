class Award < ActiveRecord::Base
  default_scope :order => "created_at ASC", :include => :award_type
  belongs_to :award_type
  has_many :product_awards, :dependent => :destroy
  
  validates :name, :length => { :maximum => 150 }, :presence => true
  
  def full_name
    if (name == "-")
      award_type.name
    else
      "#{award_type.name} #{name}"
    end
  end
end
