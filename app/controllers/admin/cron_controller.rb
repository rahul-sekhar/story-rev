class Admin::CronController < Admin::ApplicationController
  before_filter :require_admin
  
  def image_cron
    @title = "Image Clearing Cron"
    @cover_images = CoverImage.includes(:product).all
    @cover_images.each do |i|
      if (i.product_id.blank? && ((Date.today.day - i.created_at.day) > 1))
        i.destroy
      end
    end
  end
end