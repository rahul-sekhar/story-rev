class Admin::OthersController < Admin::ApplicationController
  def priorities
    @title = "Priorities"
    @class = "others priorities"
    @awards = AwardType.prioritised
    @authors = Author.prioritised
    @illustrators = Illustrator.prioritised
    @publishers = Publisher.prioritised
    @collections = Collection.prioritised
    @product_types = ProductType.prioritised
  end
end