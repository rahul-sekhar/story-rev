class ErrorsController < ApplicationController
  def error_404
    @class = "error-page"
    @not_found_path = params[:not_found]
  end
end