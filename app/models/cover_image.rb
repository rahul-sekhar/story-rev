class CoverImage < ActiveRecord::Base
  mount_uploader :filename, CoverUploader
  attr_accessible :filename
  
  before_save :store_dimensions
  
  belongs_to :book
  
  validates :filename, :presence => true, :file_size => { :maximum => 4.megabytes.to_i }
  
  def self.clear_old
    cleared = 0
    CoverImage.includes(:book).where("updated_at < current_timestamp - INTERVAL '1 day'").each do |i|
      if i.book_id.blank?
        puts "Deleted: #{i.file_info[:name]} (#{i.file_info[:size]}) \t\t [#{i.created_at}]"
        i.destroy
        cleared += 1
      end
    end
    
    puts "Cleared #{cleared} old images"
  end
  
  def store_dimensions
    self.width = filename.get_dimensions[0].to_i
    self.height = filename.get_dimensions[1].to_i
  end
  
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
  
  def ratio
    @ratio ||= (height.to_f / width)
  end
  
  # Calculate version dimensions
  def medium_width
     ratio > 1.5 ? (270.to_f / ratio).round : 180
  end
  def medium_height
    ratio < 1.5 ? (ratio * 180).round : 270
  end
  
  def thumb_width
     ratio > 1.5 ? (150.to_f / ratio).round : 100
  end
  def thumb_height
    ratio < 1.5 ? (ratio * 100).round : 150
  end
  
  def tiny_width
     ratio > 1.5 ? (60.to_f / ratio).round : 40
  end
  def tiny_height
    ratio < 1.5 ? (ratio * 40).round : 60
  end
  
end
