class Admin::LoansController < Admin::ApplicationController
  before_filter :require_admin

  def index
    @title = "Finances Loans"
    @class = "finances loans"
    
    @loans = Loan.all
    
    respond_to do |format|
      format.html
      format.json { render json: @loans.map { |x| present(x).as_hash }}
    end
  end

  def create
    @loan = Loan.new(params[:loan])
    
    respond_to do |format|
      if @loan.save
        format.json {render json: present(@loan).as_hash }
      else
        format.json { render json: @loan.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end
  
  def update
    @loan = Loan.find(params[:id])
    respond_to do |format|
      if @loan.update_attributes(params[:loan])
        format.json { render json: present(@loan).as_hash }
      else
        format.json { render json: @loan.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @loan = Loan.find(params[:id])
    @loan.destroy
    respond_to do |format|
      format.json { render json: { success: true }}
    end
  end
end