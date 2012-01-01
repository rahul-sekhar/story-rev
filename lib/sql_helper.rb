module SqlHelper
  def self.escapeWildcards (data, reverse = false)
    if reverse
      data.gsub('\\\\', '\\').gsub('\\%', '%').gsub('\\_', '_')
    else
      data.gsub('\\', '\\\\\\\\').gsub('%', '\\%').gsub('_', '\\_')
    end
  end
end