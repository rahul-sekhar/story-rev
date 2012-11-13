class OrderCopyPresenter < BasePresenter
  presents :order_copy

  def as_hash
    {
      id: order_copy.id,
      title: book.title,
      author_name: book.author_name,
      accession_id: copy.accession_id,
      price: copy.price,
      format_name: copy.format_name,
      isbn: copy.isbn,
      new_copy: copy.new_copy,
      condition_rating: copy.new_copy ?  nil : copy.condition_rating,
      condition_description: copy.new_copy ? copy.condition_description : nil,
      number: copy.new_copy ? order_copy.number : nil,
      ticked: order_copy.ticked
    }
  end

  private

  def copy
    present(order_copy.copy)
  end

  def book
    present(order_copy.copy.book)
  end
end