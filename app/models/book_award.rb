class BookAward < ActiveRecord::Base
  self.table_name = :books_awards
  default_scope includes(:award)

  attr_accessible :year, :award_id
  
  belongs_to :book
  belongs_to :award
  
  validates :award_id, :presence => true
  validates :year, :numericality => { :only_integer => true, :greater_than => 1000, :less_than => 2100 }, :allow_blank => true
  
  def full_name
    if year.present?
      "#{award.full_name} #{year}"
    else
      award.full_name
    end
  end
end
