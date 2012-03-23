class CoverImage < ActiveRecord::Base
  mount_uploader :filename, CoverUploader
  
  before_save :store_dimensions
  
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
  
  def medium_url
    filename.medium.url
  end
  
  def tiny_url
    filename.tiny.url
  end
  
  def url
    filename.url
  end
  
  def store_dimensions
    self.medium_width = filename.medium.get_version_dimensions[0].to_i
    self.medium_height = filename.medium.get_version_dimensions[1].to_i
  end
end
