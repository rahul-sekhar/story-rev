class Admin::AwardsController < Admin::ApplicationController
  
  def index
    @awards = Award.order("name").where(:award_type_id => params[:award_type_id])
    respond_to do |format|
      format.json { render :json => @awards, :only => [:id, :name] }
    end
  end
  
  def create
    @award_type = AwardType.find(params[:award_type_id])
    @award = @award_type.awards.build(params[:award])
    respond_to do |format|
      if @award.save
        format.json { render :json => @award, :only => [:id, :name] }
      else
        format.json { render :json => @award.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end
  
end
