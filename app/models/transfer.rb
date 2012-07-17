class Transfer < ActiveRecord::Base
  after_initialize :init

  belongs_to :source_account, class_name: "Account"
  belongs_to :target_account, class_name: "Account"
  belongs_to :transfer_category
  belongs_to :payment_method

  delegate :name, to: :transfer_category, prefix: true, allow_nil: true
  delegate :name, to: :payment_method, prefix: true, allow_nil: true
  delegate :name, to: :source_account, prefix: true, allow_nil: true
  delegate :name, to: :target_account, prefix: true, allow_nil: true

  validates :source_account, presence: true
  validates :target_account, presence: true

  # Scope for transactions between two dates
  # 'between_exclusive' excludes the end day
  def self.between_exclusive(from, to)
    where("date >= ? AND date < ?", from, to)
  end
  # 'between' includes the end day
  def self.between(from, to)
    between_exclusive(from, to + 1.day)
  end

  def self.first_date
    first_transfer = order("date asc").first
    return first_transfer ? first_transfer.date.to_date : Date.new(1900)
  end

  def init
    self.amount ||= 0
  end
  
  def check_data
    self.date = DateTime.now if date.nil?
    return nil
  end

  def formatted_amount
    (amount && amount > 0) ? RupeeHelper.to_rupee(amount) : '-'
  end

  # Format date as in 'Nov 19, 2012'
  def formatted_date
    date.strftime("%b %e, %Y")
  end
  
  def timestamp
    date.to_i
  end

  def short_date
    date.strftime("%d-%m-%Y")
  end
  
  def short_date=(val)
    self.date = DateTime.strptime(val, "%d-%m-%Y")
  end

  def get_hash
    {
      :id => id,
      :formatted_date => formatted_date,
      :short_date => short_date,
      :timestamp => timestamp,
      :transfer_category_name => transfer_category_name,
      :transfer_category_id => transfer_category_id,
      :payment_method_name => payment_method_name,
      :payment_method_id => payment_method_id,
      :source_account_name => source_account_name,
      :source_account_id => source_account_id,
      :target_account_name => target_account_name,
      :target_account_id => target_account_id,
      :notes => notes,
      :amount => amount,
      :formatted_amount => formatted_amount
    }
  end
end