class BookPresenter < BasePresenter
  presents :book
  delegate :title, :author_name, :illustrator_name, :short_description, to: :book

  def inner_cover(link_to_image = false)
    if book.cover_image.present?
      link_to (link_to_image ? book.cover_image.url : book_path(book)), class: (link_to_image ? nil : "book-link") do
          
          image_tag book.cover_image.thumb_url,
            alt: "#{author_name} \u2012 #{title}",
            width: book.cover_image.thumb_width,
            height: book.cover_image.thumb_height

      end
    else
      content_tag :div, class: "blank-cover" do
        if link_to_image || book.new_record?
          content_tag(:p, title, class: :title) + 
          content_tag(:p, author_name, class: :author)
        else
          link_to book_path(book), class: "book-link" do
            content_tag(:p, title, class: :title) + 
            content_tag(:p, author_name, class: :author)
          end
        end
      end
    end
  end

  def tiny_cover
    return nil if book.cover_image.blank?

    link_to book_path(book), class: "book-link" do
      image_tag book.cover_image.tiny_url,
        alt: "#{author_name} \u2012 #{title}",
        width: book.cover_image.tiny_width,
        height: book.cover_image.tiny_height
    end
  end

  def title_link
    link_to title, book_path(book), class: "book-link"
  end

  def age_level
    if (book.age_from && book.age_to)
      if (book.age_from == book.age_to)
        "#{book.age_from}"
      else
        "#{book.age_from} \u2012 #{book.age_to}"
      end
    elsif book.age_from
      "#{book.age_from}+"
    else
      ""
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
