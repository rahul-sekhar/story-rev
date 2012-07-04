module Tag
  
  module ClassMethods
    include FindableByName

    def from_list (word_list)
      # Remove duplicates
      unique_names = []

      word_list.split(",")
        .map { |x| x.strip }
        .select do |x|
          if x.blank? || unique_names.include?(x.downcase)
            false
          else
            unique_names << x.downcase
            true
          end
        end
        .map do |x|
          name_is(x) || new(name: x)
        end
    end
    
  end
  
  def self.included(base)
    base.extend ClassMethods
  end
end