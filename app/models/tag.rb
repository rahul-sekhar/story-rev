module Tag
  
  module ClassMethods
    def split_list (word_list)
      word_list.split(",").reject { |w| w.blank? }.map do |w|
        (find_by_iname(w)) || (new({ :name => w.strip }))
      end
    end
    
    def name_like(data)
      where("LOWER(name) like ?", "%#{SqlHelper::escapeWildcards(data.downcase)}%")
    end

    def find_by_iname(name)
      self.where('LOWER(name) = ?', name.strip.downcase).first
    end
  end
  
  def self.included(base)
    base.extend ClassMethods
  end
end