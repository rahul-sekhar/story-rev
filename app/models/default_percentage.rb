class DefaultPercentage < ActiveRecord::Base
  belongs_to :publisher

  validates :publisher, presence: true
  validates :publisher_id, uniqueness: true
  validates :percentage, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100
  }

  delegate :name, to: :publisher, prefix: true
end