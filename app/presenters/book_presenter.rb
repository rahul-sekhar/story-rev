class BookPresenter < BasePresenter
  presents :book

  def age_level
    if (book.age_from && book.age_to)
      if (book.age_from == book.age_to)
        "#{book.age_from}"
      else
        "#{book.age_from} - #{book.age_to}"
      end
    elsif book.age_from
      "#{book.age_from}+"
    else
      ""
    end
  end
  
  def creators
    "#{book.author_name}#{book.illustrator.present? && book.illustrator_name != book.author_name ? " and #{book.illustrator_name}" : ""}"
  end
  
  def used_copy_min_price
    min = book.used_copy_min_price
    to_currency(min) unless min.nil?
  end
  
  def new_copy_min_price
    min = book.new_copy_min_price
    to_currency(min) unless min.nil?
  end
  
  def award_list
    book_awards.map {|x| x.full_name}.join(", ")
  end
  
  def as_collection_hash
    {
      :id => book.id,
      :title => book.title,
      :author_name => book.author_name,
      :age_level => age_level,
      :stock => book.number_of_copies
    }
  end
  
  def as_list_hash
    {
      :id => book.id,
      :title => book.title,
      :author_name => book.author_name,
      :author_last_name => book.author.last_name,
      :illustrator_name => book.illustrator_name,
      :illustrator_last_name => book.illustrator.present? ? book.illustrator.last_name : nil,
      :age_level => age_level,
      :age_from => book.age_from,
      :collection_list => book.collection_list,
      :award_list => book.award_list,
      :stock => book.number_of_copies
    }
  end
  
  
end
