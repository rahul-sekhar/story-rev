class Admin::ThemesController < Admin::ApplicationController
  respond_to :json
  
  def index
    @class = "themes"
    @themes = Theme.includes(:theme_icon).all
  end
  
  def create
    @theme = Theme.new(params[:theme])
    if @theme.save
      render :json => @theme.get_hash
    else
      render :json => @theme.errors.full_messages, :status => :unprocessable_entity
    end
  end
  
  def update
    @theme = Theme.find(params[:id])
    if @theme.update_attributes(params[:theme])
      render :json => @theme.get_hash
    else
      render :json => @theme.errors.full_messages, :status => :unprocessable_entity
    end
  end
  
  def destroy
    @theme = Theme.find(params[:id])
    @theme.destroy
    render :json => { :success => true }
  end
  
end
