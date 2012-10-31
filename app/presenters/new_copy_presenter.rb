class NewCopyPresenter < BasePresenter
  presents :copy

  def accession_id_sortable
    "#{copy.accession_id.to_i}.#{copy.copy_number}".to_f
  end

  def price
    CurrencyMethods.to_currency(copy.price)
  end

  def as_hash
    if new_copy
      return {
        :id => copy.id,
        :accession_id => copy.accession_id,
        :accession_id_sortable => copy.accession_id_sortable,
        :price => copy.price,
        :formatted_price => to_currency(copy.price),
        :new_copy => copy.new_copy,
        :stock => copy.stock,
        :required_stock => copy.required_stock
      }
    else
      return {
        :id => copy.id,
        :accession_id => copy.accession_id,
        :accession_id_sortable => copy.accession_id_sortable,
        :price => copy.price,
        :formatted_price => to_currency(copy.price),
        :condition_description => condition_description,
        :condition_rating => copy.condition_rating,
        :new_copy => copy.new_copy
      }
    end
  end
end
