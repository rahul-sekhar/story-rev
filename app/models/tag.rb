module Tag
  
  module ClassMethods
    def split_list (word_list)
      word_list.split(",").reject { |w| w.blank? }.map do |w|
        (self.where('LOWER(name) = ?', w.strip.downcase).first) || (self.new({ :name => w.strip }))
      end
    end
    
    def name_like(data)
      where("LOWER(name) like ?", "%#{SqlHelper::escapeWildcards(data.downcase)}%")
    end
  end
  
  def self.included(base)
    base.extend ClassMethods
  end
end