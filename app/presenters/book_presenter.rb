class BookPresenter < BasePresenter
  presents :book
  delegate :title, :author_name, :illustrator_name, :short_description, to: :book

  def has_cover_image?
    book.cover_image.present?
  end

  def cover_image(type)
    raise "Invalid book cover image type" if !%w[tiny thumb medium].include?(type)
    image_tag book.cover_image.send("#{type}_url"),
      alt: "#{author_name} \u2012 #{title}",
      width: book.cover_image.send("#{type}_width"),
      height: book.cover_image.send("#{type}_height")
  end

  def title_and_author_p
    content_tag(:p, title, class: :title) + 
    content_tag(:p, author_name, class: :author)
  end

  def inner_cover(link_to_image = false)
    if book.cover_image.present?
      link_to cover_image("thumb"), 
        link_to_image ? book.cover_image.url : book_path(book),
        class: (link_to_image ? nil : "book-link")
    else
      content_tag :div, class: "blank-cover" do
        if link_to_image || book.new_record?
          title_and_author_p
        else
          link_to title_and_author_p, book_path(book), class: "book-link"
        end
      end
    end
  end

  def tiny_cover
    link_to cover_image("tiny"), book_path(book), class: "book-link" if has_cover_image?
  end

  def amazon_link
    if book.amazon_url.present?
      content_tag :p, class: "amazon-link" do
        link_to "View reviews on amazon", book.amazon_url, class: "ext"
      end
    end
  end

  def title_link
    link_to title, book_path(book), class: "book-link"
  end

  def age_level(add_age = false)
    if book.age_from.blank?
      ""
    elsif book.age_to.present? && (book.age_from != book.age_to)
      "#{"ages " if add_age}#{book.age_from} \u2012 #{book.age_to}"
    else
      "#{"age " if add_age}#{book.age_from}"
    end
  end

  def age_message
    if book.age_from.present?
      content_tag :p, class: :age do
        "May be appropriate for ".html_safe +
        content_tag(:span, age_level(true)) +
        content_tag(:span, '(and up)', class: "sidenote")
      end
    end
  end

  def publisher_message
    if book.publisher.present?
      content_tag :p, class: :publisher do
        "Publisher: ".html_safe +
        content_tag(:span, book.publisher_name)
      end
    end
  end

  def year_message
    if book.year.present?
      content_tag :p, class: :year do
        "First published in: ".html_safe +
        content_tag(:span, book.year)
      end
    end
  end
  
  def creators
    if book.illustrator.present? && illustrator_name != author_name
      "#{author_name} and #{illustrator_name}"
    else
      author_name
    end
  end
  
  def used_copy_min_price
    min = book.used_copy_min_price
    CurrencyMethods.to_currency(min) unless min.nil?
  end
  
  def new_copy_min_price
    min = book.new_copy_min_price
    CurrencyMethods.to_currency(min) unless min.nil?
  end
  
  def award_list
    book.book_awards.map {|x| x.full_name}.join(", ")
  end
  
  def as_collection_hash
    {
      :id => book.id,
      :title => title,
      :author_name => author_name,
      :age_level => age_level,
      :stock => book.number_of_copies
    }
  end
  
  def as_list_hash
    {
      :id => book.id,
      :title => title,
      :author_name => author_name,
      :author_last_name => book.author.last_name,
      :illustrator_name => illustrator_name,
      :illustrator_last_name => book.illustrator.present? ? book.illustrator.last_name : nil,
      :age_level => age_level,
      :age_from => book.age_from,
      :collection_list => book.collection_list,
      :award_list => award_list,
      :stock => book.number_of_copies
    }
  end
end
