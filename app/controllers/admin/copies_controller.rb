class Admin::CopiesController < Admin::ApplicationController
  
  def index
    @edition = Edition.find(params[:edition_id])
    
    if (params[:new])
      @copies = @edition.new_copies
    elsif (params[:used])
      @copies = @edition.used_copies.stocked
    else
      @copies = @edition.copies.new_or_stocked
    end
    
    respond_to do |format|
      format.json { render json: @copies.map { |x| present(x).as_hash }}
    end
  end
  
  def create
    @edition = Edition.find(params[:edition_id])
    if (params[:new])
      @copy = @edition.new_copies.build(params[:copy])
    else
      @copy = @edition.used_copies.build(params[:copy])
    end
    
    respond_to do |format|
      if @copy.save
        format.json {render json: present(@copy).as_hash }
      else
        format.json { render json: @copy.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end
  
  def update
    @copy = Copy.find_used_or_new(params[:id])
    respond_to do |format|
      if @copy.update_attributes(params[:copy])
        format.json { render json: present(@copy).as_hash }
      else
        format.json { render json: @copy.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @copy = Copy.find(params[:id])
    @copy.destroy
    respond_to do |format|
      format.json { render json: { success: true }}
    end
  end
end
