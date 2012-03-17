module Person
  
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
  
  module ClassMethods
    def name_is(name)
      # Add a space for a single worded name
      name = " #{name}" if !name.include? ' '
      
      where("LOWER(first_name || ' ' || last_name) = ?", name.downcase).first
    end
    
    def name_like(name)
      where("LOWER(first_name || ' ' || last_name) like ?", "%#{SqlHelper::escapeWildcards(name.downcase)}%")
    end
  end
  
  def self.included(base)
    base.extend ClassMethods
  end
end
