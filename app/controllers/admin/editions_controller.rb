class Admin::EditionsController < Admin::ApplicationController
  
  def index
    @editions = Book.find_by_accession_id(params[:book_id]).editions
    
    render json: @editions.map{ |x| present(x).as_hash }
  end
  
  def create
    @book = Book.find_by_accession_id(params[:book_id])
    @edition = @book.editions.build(params[:edition])
    respond_to do |format|
      if @edition.save
        format.json { render json: present(@edition).as_hash }
      else
        format.json { render json: @edition.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end
  
  def update
    @edition = Edition.find(params[:id])
    respond_to do |format|
      if @edition.update_attributes(params[:edition])
        format.json { render json: present(@edition).as_hash }
      else
        format.json { render json: @edition.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @edition = Edition.find(params[:id])
    @edition.destroy
    respond_to do |format|
      format.json { render json: { success: true }}
    end
  end
  
end
