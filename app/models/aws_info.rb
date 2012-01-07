class AWSInfo
  require 'amazon/ecs'
  
  def self.search(title)
    
    init
    res = get_xml(title)
    objects = []
    
    res.items.each do |x|
      attrs = x.get_element('ItemAttributes')
      item_title = attrs.get('Title')
      
      next if !filter(item_title)
      
      objects << {
        :isbn => attrs.get('ISBN'),
        :author => attrs.get('Author'),
        :title => item_title,
        :illustrator => get_illustrator(attrs),
        :publisher => attrs.get('Publisher'),
        :publicationDate => attrs.get('PublicationDate'),
        :age => attrs.get('ReadingLevel'),
        :pages => attrs.get('NumberOfPages'),
        :details => x.get('DetailPageURL'),
        :amazonid => x.get('ASIN'),
        :image => x.get('LargeImage/URL'),
        :imageWidth => x.get('LargeImage/Width'),
        :imageHeight => x.get('LargeImage/Height'),
      }
    end
    
    return objects
  end
  
  private
  
  def self.init
    Amazon::Ecs.options = {
      :associate_tag => '5167',
      :AWS_access_key_id => 'AKIAIMMG6WABQLP65PYQ',       
      :AWS_secret_key => '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'
    }
  end
  
  def self.get_xml(title)
    return Amazon::Ecs.item_search(
      title,
      :response_group => 'ItemAttributes,EditorialReview,Images',
      :search_index => 'Books'
    )
  end
  
  def self.filter(title)
    word_filter = %w[Digest Collection Guide]
    
    word_filter.each do |w|
      return false if (title.downcase.index(w.downcase))
    end
    
    return true
  end
  
  def self.get_illustrator(item_attrs)
    creators = item_attrs.get_elements('Creator')
    if !creators
      return
    end
    creators.each do |c|
      if c.attributes['Role'].value.downcase == 'illustrator'
        return c.get
      end
    end
  end
end
