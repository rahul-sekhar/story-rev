class Admin::NewCopiesController < Admin::ApplicationController
  
  def index
    @edition = Edition.find(params[:edition_id])
    respond_to do |format|
      format.json { render :json => @edition.new_copies.map { |x| x.get_hash }}
    end
  end
  
  def create
    @edition = Edition.find(params[:edition_id])
    @new_copy = @edition.new_copies.build(params[:new_copy])
    respond_to do |format|
      if @new_copy.save
        format.json {render :json => @new_copy.get_hash }
      else
        format.json { render :json => @new_copy.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end
  
  def update
    @new_copy = NewCopy.find(params[:id])
    respond_to do |format|
      if @new_copy.update_attributes(params[:new_copy])
        format.json { render :json => @new_copy.get_hash }
      else
        format.json { render :json => @new_copy.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @new_copy = NewCopy.find(params[:id])
    @new_copy.destroy
    respond_to do |format|
      format.json { render :json => { :success => true }}
    end
  end
end
