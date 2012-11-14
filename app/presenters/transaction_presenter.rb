class TransactionPresenter < BasePresenter
  presents :transaction

  delegate :id, 
    :short_date, 
    :transaction_category_id, 
    :transaction_category_name, 
    :other_party,
    :payment_method_name,
    :payment_method_id,
    :notes,
    :credit,
    :debit,
    to: :transaction

  def formatted_credit
    credit > 0 ? CurrencyMethods.to_currency(credit) : '-'
  end
  
  def formatted_debit
    debit > 0 ? CurrencyMethods.to_currency(debit) : '-'
  end

  # Format date as in 'Nov 19, 2012'
  def formatted_date
    transaction.date.strftime("%b %e, %Y")
  end

  def order_url
    return transaction.complete_order.present? ? present(transaction.complete_order).get_url : nil
  end

  def timestamp
    transaction.date.to_i
  end

  def as_hash
    {
      id: id,
      formatted_date: formatted_date,
      short_date: short_date,
      timestamp: timestamp,
      transaction_category_name: transaction_category_name,
      transaction_category_id: transaction_category_id,
      other_party: other_party,
      payment_method_name: payment_method_name,
      payment_method_id: payment_method_id,
      notes: notes,
      credit: credit,
      formatted_credit: formatted_credit,
      debit: debit,
      formatted_debit: formatted_debit,
      order_url: order_url
    }
  end
end