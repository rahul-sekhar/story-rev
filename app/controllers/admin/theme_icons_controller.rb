class Admin::ThemeIconsController < Admin::ApplicationController
  respond_to :json
  
  def create
    @theme_icon = ThemeIcon.new
    @theme_icon.filename = params[:image_file]
    if @theme_icon.save
      render :json => @theme_icon.file_info
    else
      render :json => @theme_icon.errors.full_messages, :status => 406
    end
  end

  def destroy
    ThemeIcon.find(params[:id]).destroy
    render :json => { :success => true }
  end
end
