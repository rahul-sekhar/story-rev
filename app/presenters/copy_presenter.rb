class CopyPresenter < BasePresenter
  presents :copy

  delegate :title_link, to: :book
  delegate :creators, to: :book
  delegate :format_name, to: :edition
  delegate :isbn, to: :edition
  delegate :publisher_name, to: :edition
  delegate :accession_id, to: :copy
  delegate :new_copy, to: :copy
  delegate :condition_rating, to: :copy
  delegate :new_copy, to: :copy

  def accession_id_sortable
    "#{copy.accession_id.to_i}.#{"%04d" % copy.copy_number.to_i}".to_f
  end

  def condition_description
    copy.condition_description || condition_to_words(copy.condition_rating)
  end

  def price
    CurrencyMethods.to_currency(copy.price)
  end

  def cost_price
    CurrencyMethods.to_currency(copy.cost_price)
  end

  def tiny_book_cover
    book.tiny_cover
  end

  def as_hash
    {
      id: copy.id,
      accession_id: copy.accession_id,
      accession_id_sortable: accession_id_sortable,
      price: copy.price,
      formatted_price: price,
      new_copy: copy.new_copy,
      stock: copy.stock,
      required_stock: copy.required_stock || 0,
      condition_description: condition_description,
      condition_rating: copy.condition_rating,
      cost_price: copy.cost_price,
      formatted_cost_price: cost_price,
      profit_percentage: copy.profit_percentage
    }
  end

  private

  def condition_to_words(condition)
    case condition.to_i
    when 1
      "Acceptable"
    when 2
      "Acceptable"
    when 3
      "Good"
    when 4
      "Excellent"
    when 5
      "Like new"
    end
  end

  def book
    present(copy.book)
  end

  def edition
    copy.edition
  end
end
