class Admin::EditionsController < Admin::ApplicationController
  
  def update
    @edition = Edition.find(params[:id])
    respond_to do |format|
      if @edition.update_attributes(params[:edition])
        format.json do
          render :json => @edition,
            :only => [:id, :format_name, :base_price, :formatted_base_price, :isbn]
        end
      else
        format.json { render :json => @edition.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end
  
end
