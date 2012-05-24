module SqlHelper
  def self.escapeWildcards(data, reverse = false)
    if reverse
      data.gsub('\\\\', '\\').gsub('\\%', '%').gsub('\\_', '_')
    else
      data.gsub('\\', '\\\\\\\\').gsub('%', '\\%').gsub('_', '\\_')
    end
  end
  
  def self.reset_primary_key(klass)
    ActiveRecord::Base.connection.reset_pk_sequence!(klass.table_name)
  end
end