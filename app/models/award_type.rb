class AwardType < ActiveRecord::Base
  has_many :awards, :dependent => :destroy
  
  after_save :create_empty_award
  
  validates :name, :length => { :maximum => 100 }, :presence => true, :uniqueness => { :case_sensitive => false }
  
  def create_empty_award
    if Award.where(:award_type_id => id).blank?
      Award.create(:award_type_id => id, :name => "-")
    end
  end
  
end
