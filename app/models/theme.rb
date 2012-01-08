class Theme < ActiveRecord::Base
  
  has_and_belongs_to_many :products, :join_table => :products_themes, :uniq => true
  has_one :theme_icon, :dependent => :destroy
  
  validates :name, :length => { :maximum => 200 }, :presence => true, :uniqueness => { :case_sensitive => false }
  
  def icon_id
    theme_icon.present? ? theme_icon.id : nil
  end
  
  def icon_id=(img_id)
    if (theme_icon.present? && img_id != theme_icon.id)
      theme_icon.destroy
    end
    
    if img_id.present?
      self.theme_icon = ThemeIcon.find(img_id)
    end
  end
  
  def icon_url
    theme_icon.present? ? theme_icon.url : nil
  end
  
  def icon_url=(url)
    if (theme_icon.present?)
      theme_icon.destroy
    end
    
    self.theme_icon = ThemeIcon.new(:remote_filename_url => url)
  end
  
  def icon_data_json
    {
      :id => icon_id,
      :url => icon_url
    }.to_json
  end
  
  def get_hash
    {
      :id => id,
      :name => name,
      :icon_url => icon_url,
      :icon_data_json => {
        :id => icon_id,
        :url => icon_url
      }
    }
  end
end
