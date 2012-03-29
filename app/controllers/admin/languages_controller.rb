class Admin::LanguagesController < Admin::ApplicationController
  
  def create
    @language = Language.new(params[:language])
    respond_to do |format|
      if @language.save
        format.json { render :json => @language, :only => [:id, :name] }
      else
        format.json { render :json => @language.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end
  
end
