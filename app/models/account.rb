class Account < ActiveRecord::Base
  extend FindableByName
  
  attr_accessible :name, :share

  validate :check_sum_of_shares

  has_many :account_profit_shares, dependent: :destroy

  validates :name, length: { maximum: 120 }, presence: true, uniqueness: { case_sensitive: false }
  validates :share, numericality: { 
    only_integer: true, 
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100
  }

  strip_attributes

  def amount_due
    account_profit_shares.inject(0){ |s, x| s + x.amount }
  end

  def check_sum_of_shares
    if sum_of_other_shares + share.to_i > 100
      errors.add(:share, "cannot exceed 100% in total") 
    end
  end

  def sum_of_other_shares
    Account.where{id != my{self.id}}.inject(0){ |s, x| s + x.share }
  end
end
