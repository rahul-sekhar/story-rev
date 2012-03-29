class Admin::ContentTypesController < Admin::ApplicationController
  
  def create
    @content_type = ContentType.new(params[:content_type])
    respond_to do |format|
      if @content_type.save
        format.json { render :json => @content_type, :only => [:id, :name] }
      else
        format.json { render :json => @content_type.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end
  
end
