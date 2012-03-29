class Admin::CopiesController < Admin::ApplicationController
  
  def index
    @edition = Edition.find(params[:edition_id])
    respond_to do |format|
      format.json { render :json => @edition.copies.stocked.map { |x| x.get_hash }}
    end
  end
  
  def create
    @edition = Edition.find(params[:edition_id])
    @copy = @edition.copies.build(params[:copy])
    respond_to do |format|
      if @copy.save
        format.json {render :json => @copy.get_hash }
      else
        format.json { render :json => @copy.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end
  
  def update
    @copy = Copy.find(params[:id])
    respond_to do |format|
      if @copy.update_attributes(params[:copy])
        format.json { render :json => @copy.get_hash }
      else
        format.json { render :json => @copy.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @copy = Copy.find(params[:id])
    @copy.destroy
    respond_to do |format|
      format.json { render :json => { :success => true }}
    end
  end
end
