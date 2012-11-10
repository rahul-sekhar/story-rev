module Person
  def name
    first_name.blank? ? last_name : "#{first_name} #{last_name}"
  end
  
  def name=(val)
    split_name = val.split
    self.last_name = split_name.pop
    while !split_name.empty? && ("a".."z").member?(split_name.last[0,1])
      self.last_name = "#{split_name.pop} #{last_name}"
    end
    self.first_name = split_name.join(" ")
  end

  def name_must_be_unique
    my_id = id
    if self.class.scoped_name_is(name).where{id != my_id}.present?
      errors.add(:name, "must be unique")
    end
  end
  
  module ClassMethods
    # Returns a single person that has the passed name
    def name_is(name)
      scoped_name_is(name).first
    end

    # Returns an ActiveRecord relation containing people with the passed name
    def scoped_name_is(name)
      name = SqlHelper::escapeWildcards(name)
      where do
        first_name.op('||', ' ').op('||', last_name).like(name) | 
        first_name.op('||', last_name).like(name) 
      end
    end
    
    # Returns an ActiveRecord relation containing people whos name includes the passed string
    def name_like(name)
      name = SqlHelper::escapeWildcards(name)
      where{first_name.op('||', ' ').op('||', last_name).like("%#{name}%")}
    end
  end
  
  def self.included(base)
    base.extend ClassMethods
  end
end
