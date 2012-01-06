class Admin::CoverImagesController < Admin::ApplicationController
  respond_to :json
  
  def create
    @cover_image = CoverImage.new
    @cover_image.filename = params[:image_file]
    if @cover_image.save
      render :json => @cover_image.file_info
    else
      render :json => @cover_image.errors.full_messages, :status => 406
    end
  end

  def destroy
    CoverImage.find(params[:id]).destroy
    render :json => { :success => true }
  end
end
