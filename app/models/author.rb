class Author < ActiveRecord::Base
  attr_writer :full_name
  
  has_many :products, :dependent => :destroy
  
  validates :full_name, :length => { :maximum => 150 }, :presence => true
  
  before_save :convert_full_name
  
  def full_name
    @full_name ||= (first_name.blank? ? last_name : "#{first_name} #{last_name}")
  end
  
  def convert_full_name
    split_name = full_name.split
    self.last_name = split_name.pop
    while !split_name.empty? && ("a".."z").member?(split_name.last[0,1])
      self.last_name = "#{split_name.pop} #{last_name}"
    end
    self.first_name = split_name.join(" ")
  end
end
