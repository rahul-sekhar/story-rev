class CopyDecorator < ApplicationDecorator
  decorates :copy

  def accession_id_sortable
    "#{copy.accession_id.to_i}.#{copy.copy_number}".to_f
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

  def condition_description
    copy.condition_description.present? ? copy.condition_description : condition_to_words(copy.condition_rating)
  end

  private
  
  def condition_to_words(condition)
    case condition
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
end
