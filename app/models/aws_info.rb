class AWSInfo
  require 'amazon/ecs'
  require 'timeout'

  def self.search(title)

    init
    objects = []

    begin
      res = Timeout.timeout(5) {
        get_xml(title)
      }
    rescue Timeout::Error
      return objects
    end

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
        :thumb => x.get('SmallImage/URL'),
        :thumbWidth => x.get('SmallImage/Width'),
        :thumbHeight => x.get('SmallImage/Height')
      }
    end

    return objects
  end

  private

  def self.init
    Amazon::Ecs.options = {
      :associate_tag => Rails.configuration.sensitive['aws_associate_tag'],
      :AWS_access_key_id => Rails.configuration.sensitive['aws_access_key_id'],
      :AWS_secret_key => Rails.configuration.sensitive['aws_secret_access_key'],
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
