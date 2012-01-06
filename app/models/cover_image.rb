class CoverImage < ActiveRecord::Base
  mount_uploader :filename, CoverUploader
  
  belongs_to :product
  
  validates :filename, :presence => true, :file_size => { :maximum => 4.megabytes.to_i }
  
  def file_info
  {
    :id => id,
    :name => File.basename(filename.url),
    :url => filename.url,
    :size => filename.size,
    :thumb => filename.thumb.url
  }
  end
  
  def thumb_url
    filename.thumb.url
  end
  
  def url
    filename.url
  end
end
