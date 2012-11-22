class Transaction < ActiveRecord::Base
  attr_accessible :credit, :debit, :other_party, :payment_method_id, :transaction_category_id, :short_date, :notes
  
  before_validation :check_date

  belongs_to :payment_method
  belongs_to :transaction_category
  belongs_to :complete_order, foreign_key: :order_id
  belongs_to :account
  
  validates :transaction_category, presence: true
  validates :other_party, length: { maximum: 200 }
  validates :date, presence: true
  validates :credit, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :debit, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  delegate :name, to: :transaction_category, prefix: true
  delegate :name, to: :payment_method, prefix: true, allow_nil: true
  
  # Scope for transactions between two dates
  # 'between_exclusive' excludes the end day
  def self.between_exclusive(from, to)
    where{(date >= from) & (date < to)}
  end
  # 'between' includes the end day
  def self.between(from, to)
    between_exclusive(from, to + 1.day)
  end

  def self.first_date
    if count > 0
      return order{date.asc}.first.date.to_date
    else
      return Date.new(1900)
    end
  end
  
  def check_date
    self.date = DateTime.now if date.nil?
  end
  
  def short_date
    date.strftime("%d-%m-%Y")
  end
  
  def short_date=(val)
    self.date = DateTime.strptime(val, "%d-%m-%Y")
  end

  # Build graph data given dates, a period and a type
  def self.graph_data(period_text, data_type, from, to)
    
    end_date = to.present? ? Date.strptime(to, "%d-%m-%Y") : (Date.today)
    start_date = from.present? ? Date.strptime(from, "%d-%m-%Y") : nil
    
    # Set a minimum range and Y-axis label
    case period_text
    when "yearly"
      min_range = 3.years
      y_label = "Year"
      start_date ||= end_date - 4.years
    when "quarterly"
      min_range = 9.months
      y_label = "Quarter"
      start_date ||= end_date - 36.months
    when "monthly"
      min_range = 1.months
      y_label = "Month"
      start_date ||= end_date - 12.months
    when "daily"
      min_range = 3.days
      y_label = "Day"
      start_date ||= end_date - 14.days
    else
      min_range = 3.weeks
      y_label = "Week"
      start_date ||= end_date - 12.weeks
    end
    
    # Set X-axis labels
    case data_type
    when "profits"
      x_label = "Profits"
    else
      x_label = "Sales"
    end
    
    # Switch the start date to the minimum start date if required
    start_date = ((end_date - min_range) < start_date) ? (end_date - min_range) : start_date
    
    # Set the first and last dates depending on the period
    case period_text
    when "yearly"
      start_date = Date.new(start_date.year)
      end_date = Date.new(end_date.year, -1, -1)
    when "quarterly"
      # Find the start date of the quarter containing the chosen start date
      start_date = Date.new(start_date.year, (((start_date.month - 1) / 3) * 3) + 1)
      # Find the end date of the quarter containing the chosen end date
      end_date = Date.new(end_date.year, (((end_date.month - 1) / 3) * 3) + 3, -1)
    when "monthly"
      start_date = Date.new(start_date.year, start_date.month)
      end_date = Date.new(end_date.year, end_date.month, -1)
    when "daily"
    else
      # Get the first day of the calendar week of the start date
      start_date = Date.commercial(start_date.cwyear, start_date.cweek)
      # Get the last day of the calendar week of the end date
      end_date = Date.commercial(end_date.cwyear, end_date.cweek, -1)
    end
    
    # Get transactions within the range, starting from the newest ones
    transactions = Transaction.between(start_date, end_date).order("date DESC")
    
    transaction_index = 0
    graph_points = 0
    graph_data = []
    max_points = 60
    prev_year = end_date.year
    
    # Loop through the transactions
    begin
      # Find the start date of the current period and the end date of the next period, and the y axis labels
      case period_text
      when "yearly"
        curr_start_date = Date.new(end_date.year)
        new_end_date = Date.new(end_date.year - 1, -1, -1)
        period_name = curr_start_date.year.to_s
      when "quarterly"
        curr_start_date = Date.new(end_date.year, end_date.month - 2)
        new_end_date = Date.new((end_date << 3).year, (end_date << 3).month, -1)
        period_name = "Quarter #{(((curr_start_date.month - 1) / 3) + 1)}"
      when "monthly"
        curr_start_date = Date.new(end_date.year, end_date.month)
        new_end_date = Date.new((end_date << 1).year, (end_date << 1).month, -1)
        period_name = "#{Date::MONTHNAMES[curr_start_date.month]}"
      when "daily"
        curr_start_date = end_date
        new_end_date = end_date - 1.day
        period_name = curr_start_date.strftime("%b %d")
      else
        curr_start_date = Date.commercial(end_date.cwyear, end_date.cweek)
        new_end_date = end_date - 1.week
        period_name = "Week #{curr_start_date.cweek}"
      end
      
      range_text = "#{curr_start_date.strftime("%b %d, %Y")} to #{end_date.strftime("%b %d, %Y")}"
      # Add the year when either the year changes or it is the last graph point
      if (period_text != "yearly") && (end_date.year != new_end_date.year || graph_points == max_points || curr_start_date <= start_date)
        period_name << ", #{(period_text == "weekly") ? curr_start_date.cwyear : curr_start_date.year}"
      end
      
      amount = 0
      while (transaction_index < transactions.length) do
        trans = transactions[transaction_index]
        trans_date = trans.date.to_date
        case period_text
        when "yearly"
          break unless trans_date.year === curr_start_date.year
        when "quarterly"
          break unless (trans_date.year === curr_start_date.year) && (((trans_date.month - 1)/ 3) === ((curr_start_date.month - 1) / 3))
        when "monthly"
          break unless (trans_date.year === curr_start_date.year) && (trans_date.month === curr_start_date.month)
        when "daily"
          break unless (trans_date.year === curr_start_date.year) && (trans_date.yday === curr_start_date.yday)
        else
          break unless (trans_date.cwyear === curr_start_date.cwyear) && (trans_date.cweek === curr_start_date.cweek)
        end
        
        # The following code executes if the transaction is within the current period
        transaction_index += 1
        case data_type
        when "profits"
          amount += trans.credit - trans.debit
        else
          # Sales by default
          amount += trans.credit
        end
      end
      
      # Find the rupee formatted amount
      formatted_amount = CurrencyMethods.formatted_currency(amount)
      
      # Add the point to the graph data array
      y_value = period_name
      x_value = { :v => amount, :f => formatted_amount }
      if period_text == "daily"
        tooltip = "#{period_name}\n#{x_label}: #{formatted_amount}"
      else
        tooltip = "#{period_name}\n#{range_text}\n#{x_label}: #{formatted_amount}"
      end
      graph_data << [y_value, x_value, tooltip]
      
      # Prepare the end date for the next cycle
      end_date = new_end_date
      graph_points += 1
      
    end while (graph_points <= max_points && curr_start_date > start_date)
    
    # Build the graph_data object in a format readable by google charts
    return {
      :cols => [{ :label => y_label, :type => "string" },
                { :label => x_label, :type => "number" },
                { :role => "tooltip", :type => "string" }],
      :rows => graph_data
    }
  end
end
