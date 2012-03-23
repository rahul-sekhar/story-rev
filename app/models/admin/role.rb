class AdminValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless Admin::Role.authenticate(value) == "admin"
      record.errors[attribute] << (options[:message] || "is not correct")
    end
  end
end

class Admin::Role < ActiveRecord::Base
  self.table_name = :admin_roles
  
  attr_accessible :password, :password_confirmation, :admin_password
  attr_accessor :password, :admin_password
  attr_writer :admin_password
  before_save :encrypt_password
  
  validates :password, :presence => true, :confirmation => true
  validates :admin_password, :admin => true
  validates :name, :presence => true
  
  def self.authenticate(password)
    self.all.each do |r|
      if r.password_hash == BCrypt::Engine.hash_secret(password, r.password_salt)
        return r.name
      end
    end
    return nil
  end
  
  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end
end