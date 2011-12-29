class Admin::Role < ActiveRecord::Base
  self.table_name = :admin_roles
  
  attr_accessible :password, :password_confirmation
  attr_accessor :password
  before_save :encrypt_password
  
  validates :password, :presence => true, :confirmation => true
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
