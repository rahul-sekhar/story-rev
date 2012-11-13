class AwardType < ActiveRecord::Base
  attr_accessible :name, :priority

  has_many :awards, :dependent => :destroy
  
  after_save :create_empty_award
  
  validates :name, 
    length: { maximum: 100 }, 
    presence: true, 
    uniqueness: { case_sensitive: false }

  strip_attributes
  
  def create_empty_award
    if Award.where(award_type_id: id).blank?
      Award.create(award_type_id: id, name: "-")
    end
  end
  
  scope :prioritised, order("priority DESC, name")
  scope :visible, where("priority > 0")
end
