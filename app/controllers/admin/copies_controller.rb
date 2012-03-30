class Admin::CopiesController < Admin::ApplicationController
  
  def index
    @edition = Edition.find(params[:edition_id])
    @copies = @edition.copies
    
    if (params[:new])
      @copies = @copies.new_copies
    elsif (params[:used])
      @copies = @copies.used_copies.stocked
    end
    
    respond_to do |format|
      format.json { render :json => @copies.map { |x| x.get_hash }}
    end
  end
  
  def create
    @edition = Edition.find(params[:edition_id])
    @copy = @edition.copies.build(params[:copy])
    
    @copy.new_copy = true if (params[:new])
    
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
