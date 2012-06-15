class Admin::BookTypesController < Admin::ApplicationController
  
  def create
    @book_type = BookType.new(params[:book_type])
    respond_to do |format|
      if @book_type.save
        format.json { render :json => @book_type, :only => [:id, :name] }
      else
        format.json { render :json => @book_type.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end
  
  def update
    @book_type = BookType.find(params[:id])
    if @book_type.update_attributes(params[:book_type])
      render :json => { :success => true }
    else
      render :json => @book_type.errors.full_messages, :status => :unprocessable_entity
    end
  end
  
end
