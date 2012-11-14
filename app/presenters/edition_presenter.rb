class EditionPresenter < BasePresenter
  presents :edition

  delegate :format_name, :language_name, :publisher_name, :isbn, to: :edition

  def as_hash
    {
      id: edition.id,
      format_name: format_name,
      publisher_name: publisher_name,
      language_name: language_name,
      isbn: isbn,
      default_cost_price: edition.default_cost_price,
      default_percentage: edition.default_percentage
    }
  end
end