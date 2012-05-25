class Transaction < ActiveRecord::Base
  after_initialize :init
  before_save :check_data
  
  belongs_to :account
  belongs_to :transaction_category
  belongs_to :payment_method
  
  has_one :order
  has_one :postage_order, :class_name => "Order", :foreign_key => :postage_transaction_id
  
  validates :account_id, :presence => true
  
  scope :on_record, where(:off_record => false)
  
  # Scope for transactions between two dates
  # 'between_exclusive' excludes the end day
  def self.between_exclusive(from, to)
    transactions = Transaction.where("date >= ? AND date < ?", from, to)
  end
  # 'between' includes the end day
  def self.between(from, to)
    between_exclusive(from, to + 1.day)
  end
  
  # The default data type is sales
  def self.sales(format, data_type, from, to)
    # Make the end date 12 AM of the following day
    end_date = to.present? ? Date.strptime(to, "%d-%m-%Y") : (Date.today + 1.day)
    start_date = from.present? ? Date.strptime(from, "%d-%m-%Y") : (end_date - 3.months)
    
    case format
    when "yearly"
      time_period = 1.year
    when "quarterly"
      time_period = 3.months
    when "monthly"
      time_period = 1.month
    when "daily"
      time_period = 1.day
    else
      # Default - weekly
      time_period = 1.week
    end
    
    a = Time.now
    transactions = Transaction.where(:date => (start_date..end_date)).order("date ASC")
    i = 0
    sales_data = []
    while (end_date - start_date).days > 1.day
      end_period = start_date + time_period
      end_period = end_date if end_period > end_date
      
      total = 0
      while (i < transactions.length) do
        trans = transactions[i]
        range = (start_date.to_datetime..(end_period.to_datetime - 1.second))
        break unless range.cover?(trans.date)
        case data_type
        when "profits"
          total += trans.credit - trans.debit
        else
          total += trans.credit
        end
        i += 1
      end
      
      formatted_total = RupeeHelper.format_rupee(total)
      formatted_end_period = end_period.strftime("%d-%m-%Y")
      if format == "daily"
        formatted_period = start_date.strftime("%b %d, %Y")
      else
        formatted_period = "#{start_date.strftime("%b %d, %Y")} to #{(end_period - 1.day).strftime("%b %d, %Y")}"
      end
      
      sales_data << {
        :date => formatted_end_period,
        :period => formatted_period,
        :total => total,
        :formatted_total => formatted_total
      }
      
      start_date = end_period
    end
    a = Time.now - a
    puts "Time taken - #{a * 1000} ms"
    sales_data
  end
  
  def init
    self.credit ||= 0
    self.debit ||= 0
  end
  
  def check_data
    self.date = DateTime.now if date.nil?
    self.off_record = transaction_category.off_record if transaction_category.present?
    return nil
  end
  
  def formatted_credit
    (credit && credit > 0) ? RupeeHelper.to_rupee(credit) : '-'
  end
  
  def formatted_debit
    (debit && debit > 0) ? RupeeHelper.to_rupee(debit) : '-'
  end
  
  # Format date as in 'Nov 19, 2012'
  def formatted_date
    date.strftime("%b %e, %Y")
  end
  
  def timestamp
    date.to_i
  end
  
  def transaction_category_name
    transaction_category && transaction_category.name
  end
  
  def payment_method_name
    payment_method && payment_method.name
  end
  
  def account_name
    account && account.name
  end
  
  def short_date
    date.strftime("%d-%m-%Y")
  end
  
  def short_date=(val)
    self.date = DateTime.strptime(val, "%d-%m-%Y")
  end
  
  def order_url
    return order.present? ? order.get_url : nil
  end
  
  def get_hash
    {
      :id => id,
      :formatted_date => formatted_date,
      :short_date => short_date,
      :timestamp => timestamp,
      :transaction_category_name => transaction_category_name,
      :transaction_category_id => transaction_category_id,
      :other_party => other_party,
      :payment_method_name => payment_method_name,
      :payment_method_id => payment_method_id,
      :account_name => account_name,
      :account_id => account_id,
      :notes => notes,
      :credit => credit,
      :formatted_credit => formatted_credit,
      :debit => debit,
      :formatted_debit => formatted_debit,
      :order_url => order_url
    }
  end
end
