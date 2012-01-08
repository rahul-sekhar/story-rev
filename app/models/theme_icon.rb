class ThemeIcon < ActiveRecord::Base
  mount_uploader :filename, ThemeIconUploader
  
  belongs_to :theme
  
  validates :filename, :presence => true, :file_size => { :maximum => 2.megabytes.to_i }
  
  def file_info
  {
    :id => id,
    :name => File.basename(filename.url),
    :url => filename.url,
    :size => filename.size,
  }
  end
  
  def url
    filename.url
  end
end
