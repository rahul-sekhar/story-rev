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
  
  def has_name?
    last_name.present?
  end
  
  def get_letter
    last_name[0] if has_name?
  end
  
  module ClassMethods
    def name_is(name)
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
