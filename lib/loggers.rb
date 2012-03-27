module Loggers
  Store = ActiveSupport::BufferedLogger.new(Rails.root.join('log/store.log'))
  
  def self.store_log(message)
     Store.info("#{Time.now.strftime("%m-%d-%y %H:%M:%S")} - #{message}")
  end
end