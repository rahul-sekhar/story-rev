class PagesController < ApplicationController
  include ApplicationHelper
  
  def store
    @class = "store"
    @title = "Store"
    
    check_price_params
    
    @products = Product.stocked.includes_cover.joins("LEFT JOIN authors AS auth ON products.author_id = auth.id").includes(:copies, :illustrator).filter(params).sort_by_param(params[:sort_by],params[:desc]).page(params[:page]).per(28)
    
    if params[:ajax].present?
      render :json => ajax_params
    else
      get_collection_lists
    end
  end
  
  private
  
  def check_price_params
    params.delete(:price) if params[:price_to].present? || params[:price_from].present?
  end
  
  def get_collection_lists
    stocked_books = Product.unscoped.stocked
    stocked_book_ids = stocked_books.map{ |x| x.id }
    stocked_editions = Edition.unscoped.where( :product_id => stocked_book_ids )
    stocked_awards = Award.unscoped.where('awards.id IN (SELECT award_id FROM products_awards WHERE product_id IN (?))', stocked_book_ids)
    
    @product_types = ProductType.visible.prioritised.where(:id => stocked_books.map{ |x| x.product_type_id })
    @formats = Format.where(:id => stocked_editions.map{ |x| x.format_id})
    @collections = Collection.prioritised.visible.where('"collections"."id" IN (SELECT collection_id FROM products_collections WHERE product_id IN (?))', stocked_book_ids)
    
    @awards = AwardType.prioritised.visible.where(:id => stocked_awards.map{ |x| x.award_type_id })
    @publishers = Publisher.prioritised.visible.where(:id => stocked_books.map{ |x| x.publisher_id })
    @authors = Author.prioritised.visible.where(:id => stocked_books.map{ |x| x.author_id })
    @illustrators = Illustrator.prioritised.visible.where(:id => stocked_books.map{|x| x.illustrator_id})
  end
  
  def ajax_params
    
    {
      :html => render_to_string(:action => "ajax_store", :layout => "ajax"),
      :sort_by => params[:sort_by],
      :desc => params[:desc],
      :base => get_base,
      :base_val => params[get_base],
      :filters => filter_list
    }
  end
end
