class Admin::PagesController < Admin::ApplicationController
  before_filter :require_admin, :only => :finances_config
  
  def priorities
    @title = "Priorities"
    @class = "others priorities"
    @awards = AwardType.prioritised
    @authors = Author.prioritised
    @illustrators = Illustrator.prioritised
    @publishers = Publisher.prioritised
    @collections = Collection.prioritised
    @book_types = BookType.prioritised
  end
  
  def finances_config
    @title = "Finances Configuration"
    @class = "finances config"
    
    @payment_methods = PaymentMethod.all
    @transaction_categories = TransactionCategory.all
    @transfer_categories = TransferCategory.all
    @accounts = Account.all
    @config_data = ConfigData.access
  end
end