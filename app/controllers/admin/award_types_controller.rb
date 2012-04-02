class Admin::AwardTypesController < Admin::ApplicationController
  
  def create
    @award_type = AwardType.new(params[:award_type])
    respond_to do |format|
      if @award_type.save
        format.json { render :json => @award_type, :only => [:id, :name] }
      else
        format.json { render :json => @award_type.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end
  
  def update
    @award_type = AwardType.find(params[:id])
    if @award_type.update_attributes(params[:award_type])
      render :json => { :success => true }
    else
      render :json => @award_type.errors.full_messages, :status => :unprocessable_entity
    end
  end
end
