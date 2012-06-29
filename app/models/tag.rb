module Tag
  
  module ClassMethods
    include FindableByName

    def split_list (word_list)
      word_list.split(",").reject { |w| w.blank? }.map do |w|
        (name_is(w.strip)) || (new({ :name => w.strip }))
      end
    end
    
  end
  
  def self.included(base)
    base.extend ClassMethods
  end
end