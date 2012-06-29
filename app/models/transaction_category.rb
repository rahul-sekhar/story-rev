class TransactionCategory < ActiveRecord::Base
  extend FindableByName
  
  attr_accessible :name, :off_record
  after_initialize :init
  
  has_many :transactions, :dependent => :nullify
  
  validates :name, :length => { :maximum => 120 }, :presence => true, :uniqueness => { :case_sensitive => false }
  
  def init
    self.off_record = false if off_record.nil?
  end
  
  def toggle_record
    self.off_record = !off_record
  end
end
